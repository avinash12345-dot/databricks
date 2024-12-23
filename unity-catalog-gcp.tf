
##used for provisioning bucker, storage credentials, external locations and permissions for those resources
resource "google_storage_bucket" "ext_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true
  logging {
    log_bucket = ""
  }
}

resource "databricks_storage_credential" "ext" {
  provider = databricks.workspace
  name     = var.storage_credential
  databricks_gcp_service_account {}
  owner        = google_service_account.databricks_sa.email
  metastore_id = var.metastore_id
}

resource "google_storage_bucket_iam_member" "unity_cred_admin" {
  bucket = google_storage_bucket.ext_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${databricks_storage_credential.ext.databricks_gcp_service_account[0].email}"
}

resource "google_storage_bucket_iam_member" "unity_cred_reader" {
  bucket = google_storage_bucket.ext_bucket.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${databricks_storage_credential.ext.databricks_gcp_service_account[0].email}"
}

resource "databricks_grants" "external_creds" {
  provider           = databricks.workspace
  storage_credential = databricks_storage_credential.ext.id
  grant {
    principal  = google_service_account.databricks_sa.email
    privileges = ["CREATE_EXTERNAL_TABLE", "CREATE_EXTERNAL_LOCATION"]
  }

  grant {
    principal  = "avinash.ravichandran@sky.uk"
    privileges = ["CREATE_EXTERNAL_TABLE", "CREATE_EXTERNAL_LOCATION"]
  }
}

resource "databricks_external_location" "some" {
  provider = databricks.workspace
  name     = var.external_location
  url      = "gs://${google_storage_bucket.ext_bucket.name}"

  credential_name = databricks_storage_credential.ext.id
  comment         = "Managed by TF"
}

resource "databricks_grants" "some" {
  provider          = databricks.workspace
  external_location = databricks_external_location.some.id
  grant {
    principal  = var.location_principal
    privileges = ["CREATE_EXTERNAL_TABLE", "READ_FILES"]
  }
}

resource "databricks_catalog" "development" {
  provider     = databricks.workspace
  owner        = var.catalog_owner
  name         = var.catalog_name
  storage_root = "gs://${google_storage_bucket.ext_bucket.name}"
  comment      = "this catalog is managed by terraform"
  properties = {
    purpose = "testing"
  }
}

resource "databricks_grants" "development_grant" {
  provider = databricks.workspace
  catalog  = databricks_catalog.development.name

  grant {
    principal  = google_service_account.databricks_sa.email
    privileges = ["ALL_PRIVILEGES"]
  }
  dynamic "grant" {
    for_each = var.grant_development
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

resource "databricks_schema" "things" {
  for_each     = var.schema
  provider     = databricks.workspace
  owner        = var.schema_owner
  catalog_name = databricks_catalog.development.id
  name         = each.value.schema_name
  comment      = "this database is managed by terraform"
  properties = {
    kind = "various"
  }
}

resource "databricks_grants" "things" {
  for_each = var.schema
  provider = databricks.workspace
  schema   = databricks_schema.things[each.key].id
  grant {
    principal  = google_service_account.databricks_sa.email
    privileges = ["ALL_PRIVILEGES"]
  }

  dynamic "grant" {
    for_each = each.value.grant
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }

}





