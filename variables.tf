##variables for vpc##
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
