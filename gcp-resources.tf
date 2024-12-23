##AR repository
resource "google_artifact_registry_repository" "my-repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "pypi"
  description   = "pypi remote docker repository"
  format        = "python"
  mode          = "REMOTE_REPOSITORY"
  remote_repository_config {
    description = "PyPi"
    python_repository {
      public_repository = "PYPI"
    }
  }
}

##DNS mapping for the URL's
locals {
  restricted_apis_ip = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7",
  ]

  sub_domains = [
    "gcp.databricks.com"
  ]

}

resource "google_dns_managed_zone" "zone1" {
  for_each = toset(local.sub_domains)
  project  = var.project_id
  name        = replace(each.value, ".", "-")
  dns_name    = format("%s.", each.value)
  description = "Domain ${each.value}"
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = var.vpc_self_link
    }
  }
}

resource "google_dns_record_set" "record_set_workspace_url" {
  for_each = google_dns_managed_zone.zone1
  project  = var.project_id
  managed_zone = each.value.name
  name         = var.record_set_workspace_url
  type         = "A"
  ttl          = 300
  rrdatas = [
    "${google_compute_address.psc_address.address}"
  ]
}

resource "google_dns_record_set" "record_set_workspace_dp" {
  for_each = google_dns_managed_zone.zone1
  project  = var.project_id
  managed_zone = each.value.name
  name         = var.record_set_workspace_dp
  type         = "A"
  ttl          = 300
  rrdatas = [
    "${google_compute_address.psc_address.address}"
  ]
}

resource "google_dns_record_set" "record_set_workspace_psc_auth" {
  for_each = google_dns_managed_zone.zone1
  project  = var.project_id
  managed_zone = each.value.name
  name         = "us-east1.gcp.databricks.com."
  type         = "A"
  ttl          = 300
  rrdatas = [
    "${google_compute_address.psc_address.address}"
  ]
}

resource "google_dns_record_set" "record_set_relay" {
  for_each = google_dns_managed_zone.zone1
  project  = var.project_id
  managed_zone = each.value.name
  name         = "tunnel.us-east1.gcp.databricks.com."
  type         = "A"
  ttl          = 300
  rrdatas = [
    "${google_compute_address.psc_address_rest.address}"
  ]
}

locals {
  restricted_apis_ips = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7",
  ]

  domains = [
    "gcr.io",
    "pkg.dev",
    "googleapis.com",
  ]

}



resource "google_dns_managed_zone" "zone" {
  for_each = toset(local.domains)
  project  = var.project_id

  name        = replace(each.value, ".", "-")
  dns_name    = format("%s.", each.value)
  description = "Domain ${each.value}"


  visibility = "private"

  private_visibility_config {
    networks {
      network_url = var.vpc_self_link
    }
  }
}
resource "google_dns_record_set" "records" {
  for_each     = toset(local.domains)
  project      = var.project_id
  name         = format("%s.", each.value)
  managed_zone = google_dns_managed_zone.zone[each.value].name
  type         = "A"
  ttl          = 300
  rrdatas      = local.restricted_apis_ips
  
}
resource "google_dns_record_set" "cname" {
  for_each     = toset(local.domains)
  project      = var.project_id
  name         = format("*.%s.", each.value)
  managed_zone = google_dns_managed_zone.zone[each.value].name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = [google_dns_record_set.records[each.value].name]
}

resource "google_compute_route" "restricted_googleapis_com" {
  project          = var.project_id
  name             = "r-gcp-restricted"
  description      = "Route for Google APIs (restricted VIP)"
  dest_range       = "199.36.153.4/30"
  network          = var.vpc_name
  next_hop_gateway = "default-internet-gateway"
}

##below resources are used to create kms for storage encryption at rest
resource "google_kms_key_ring" "databricks" {
  name     = "databricks"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "databricks" {
  name            = "databricks"
  key_ring        = google_kms_key_ring.databricks.id
  rotation_period = "2592000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account" "databricks" {
  account_id   = "databricks" #need to use "databricks"
  display_name = "Databricks SA for GKE nodes"
  project      = var.project_id
}

# # assign role to the gke default SA
resource "google_project_iam_binding" "databricks_gke_node_role" {
  project = var.project_id
  role    = "roles/container.nodeServiceAccount"
  members = [
    "serviceAccount:${google_service_account.databricks.email}"
  ]
}

resource "databricks_mws_customer_managed_keys" "this" {
  provider   = databricks.accounts
  account_id = var.account_id
  gcp_key_info {
    kms_key_id = google_kms_crypto_key.databricks.id
  }
  use_cases = ["STORAGE", "MANAGED_SERVICES"]

}

##used to create SA with required permissions
resource "google_service_account" "databricks_sa" {
  project    = var.project_id
  account_id = "databricks-sa"
}

resource "google_project_iam_custom_role" "databricks_workspace_creator" {
  role_id     = "databricks_workspace_creator"
  title       = "Databricks Workspace Creator"
  project     = var.project_id
  description = "Databricks Workspace Creator Role"
  permissions = [
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    "iam.roles.create",
    "iam.roles.delete",
    "iam.roles.get",
    "iam.roles.update",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
    "serviceusage.services.get",
    "serviceusage.services.list",
    "serviceusage.services.enable",
    "compute.networks.get",
    "compute.projects.get",
    "compute.subnetworks.get",
    "compute.forwardingRules.get",
  ]
}

data "google_iam_policy" "databricks_impersonation_data" {
  binding {
    role    = "roles/iam.serviceAccountTokenCreator"
    members = var.databricks_impersonators
  }

  binding {
    role = "roles/iam.workloadIdentityUser"
  }
}

resource "google_service_account_iam_policy" "databricks_impersonation_binding" {
  service_account_id = google_service_account.databricks_sa.name
  policy_data        = data.google_iam_policy.databricks_impersonation_data.policy_data
  lifecycle {
    ignore_changes = [policy_data]
  }
}

resource "google_project_iam_member" "databricks_sa" {
  project = var.project_id
  role    = google_project_iam_custom_role.databricks_workspace_creator.id
  member  = "serviceAccount:${google_service_account.databricks_sa.email}"
}

resource "google_project_iam_member" "databricks_workspace_sa" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = google_service_account.databricks_sa.member
}

resource "google_project_iam_member" "sa2_can_create_workspaces" {
  role    = google_project_iam_custom_role.databricks_workspace_creator.id
  member  = google_service_account.databricks_sa.member
  project = var.project_id
}

data "google_client_config" "current_data" {}

