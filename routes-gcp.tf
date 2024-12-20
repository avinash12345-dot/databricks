resource "google_compute_route" "routes" {
  for_each         = length(var.routes) > 0 ? { for r in var.routes : r.name => r } : {}
  name             = each.value.name
  description      = each.value.description
  network          = var.network
  project          = var.project_id
  dest_range       = each.value.destination_range
  next_hop_gateway = each.value.next_hop_gateway
  priority         = each.value.priority
}
