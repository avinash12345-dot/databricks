data "google_client_openid_userinfo" "me" {}
data "google_client_config" "current" {}

resource "databricks_mws_private_access_settings" "pas1" {
  provider                     = databricks.mws
  # account_id                   = var.account_id
  private_access_settings_name = var.private_access_settings_name
  region                       = var.region
  public_access_enabled        = true
}
resource "databricks_mws_workspaces" "databricks_workspace1" {
  account_id     = var.account_id
  provider       = databricks.mws
  workspace_name = var.workspace_name
  location       = var.region


  cloud_resource_container {
    gcp {
      project_id = var.project_id
    }

  }

  network_id = databricks_mws_networks.this2.network_id

  gke_config {
    connectivity_type = "PRIVATE_NODE_PUBLIC_MASTER"
    master_ip_range   = "10.3.0.16/28"
  }

  token {
    comment = "Terraform token"
  }
  private_access_settings_id = databricks_mws_private_access_settings.pas1.private_access_settings_id
  depends_on                 = [databricks_mws_networks.this2]
  pricing_tier               = "PREMIUM"

  storage_customer_managed_key_id          = databricks_mws_customer_managed_keys.this.customer_managed_key_id
  managed_services_customer_managed_key_id = databricks_mws_customer_managed_keys.this.customer_managed_key_id

}

output "databricks_token" {
  value     = databricks_mws_workspaces.databricks_workspace1.token[0].token_value
  sensitive = true
}
