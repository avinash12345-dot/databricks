##output for vpc##
output "name" {
  description = "Name of the vpc"
  value       = google_compute_network.vpc_network.name
}

output "id" {
  description = "id of the vpc"
  value       = google_compute_network.vpc_network.id
}

output "self_link" {
  description = "self_link"
  value       = google_compute_network.vpc_network.self_link
}

output "subnet_name" {
  description = "Map of Subnet Name"
  value = tomap({
    for k, f in google_compute_subnetwork.vpc_subnetwork : k => f.name
  })
}

##output for metastore##
output "metastore_id" {
  description = "metastore_id"
  value       = databricks_metastore.this.id

}

##output for delta share##
output "share_name" {
  description = ""
  value = tomap({
    for k, f in databricks_share.some : k => f.name
  })
}
output "recipient_name" {
  description = ""
  value = tomap({
    for k, f in databricks_recipient.db2db : k => f.name
  })
}

##output for schema and catalog
output "service_account" {
  value       = google_service_account.databricks_sa.email
  description = "Default SA for GKE nodes"
}

output "token" {
  value       = databricks_mws_workspaces.databricks_workspace1.token[0].token_value
  description = "token_id"
}

output "databricks_host" {
  value       = databricks_mws_workspaces.databricks_workspace1.workspace_url
  description = "databricks_host"
}

output "workspace_id" {
  value       = databricks_mws_workspaces.databricks_workspace1.workspace_id
  description = "workspace_id"
}

output "service_account_id" {
  value       = google_service_account.databricks_sa.id
  description = "Default SA ID for GKE nodes"
}

output "catalog_id" {
  value = databricks_catalog.development.id
  description = "Unity Catalog ID"
}

output "databricks_mws_workspace_url" {
  value = databricks_mws_workspaces.databricks_workspace1.workspace_url
  description = "Workspace URL"
}

