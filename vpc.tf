resource "google_compute_network" "vpc_network" {
  name                            = var.network
  project                         = var.project_id
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  for_each                 = var.subnets
  project                  = var.project_id
  name                     = each.value.name
  description              = each.value.description
  region                   = each.value.region
  ip_cidr_range            = each.value.ip_cidr_range
  network                  = google_compute_network.vpc_network.id
  secondary_ip_range       = each.value.secondary_ip_range
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  project = var.project_id
  name    = var.router
  region  = "us-east1"
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "natnew"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = "us-east1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
