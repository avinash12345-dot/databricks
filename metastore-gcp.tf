resource "databricks_metastore" "this" {
  provider                                          = databricks.accounts
  name                                              = "primary"
  region                                            = var.region
  delta_sharing_scope                               = "INTERNAL_AND_EXTERNAL"
  delta_sharing_recipient_token_lifetime_in_seconds = 0
  force_destroy                                     = true
}

resource "google_storage_bucket" "unity_metastore" {
  name          = "gcs-bucket-metastore-dev"
  location      = var.region
  force_destroy = true
  logging {
    log_bucket = "res-nbcupea-mgmt-003-logging"
  }
}

resource "databricks_metastore_data_access" "first" {
  depends_on = [
    databricks_metastore.this
  ]
  provider     = databricks.accounts
  metastore_id = databricks_metastore.this.id
  databricks_gcp_service_account {}
  name       = "default-storage-creds"
  is_default = true
  lifecycle {
    # Creating a delta share changed this
    ignore_changes = [ is_default ]
  }
}

resource "google_storage_bucket_iam_member" "unity_sa_admin" {
  bucket = google_storage_bucket.unity_metastore.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${databricks_metastore_data_access.first.databricks_gcp_service_account[0].email}"
}

resource "google_storage_bucket_iam_member" "unity_sa_reader" {
  bucket = google_storage_bucket.unity_metastore.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${databricks_metastore_data_access.first.databricks_gcp_service_account[0].email}"
}

resource "databricks_metastore_assignment" "this1" {
  provider             = databricks.accounts
  workspace_id         = var.workspace_id
  metastore_id         = databricks_metastore.this.id
  default_catalog_name = "hive_metastore"
}

# resource "databricks_grants" "default" {
#   provider = databricks.workspace
#   schema   = "main.default"
#   dynamic "grant" {
#     for_each = var.grant_default
#     content {
#       principal  = grant.value.principal
#       privileges = grant.value.privileges
#     }
#   }
# }

resource "databricks_grants" "all_grants" {
  provider  = databricks.workspace
  metastore = databricks_metastore.this.id
  grant {
    principal  = var.google_service_account
    privileges = ["CREATE_CATALOG", "CREATE_EXTERNAL_LOCATION", "CREATE_STORAGE_CREDENTIAL", "CREATE_CONNECTION"]
  }

  dynamic "grant" {
    for_each = var.grant
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }

  depends_on = [
    databricks_metastore_assignment.this1
  ]
}
