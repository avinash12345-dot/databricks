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
