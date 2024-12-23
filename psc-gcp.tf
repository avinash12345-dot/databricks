##used to create private connections for gcp with databricks 
resource "google_compute_subnetwork" "psc" {
  project                  = var.project_id
  name                     = "psc-endpoints-${var.region}"
  description              = "PSC endpoints for ${var.region}"
  region                   = var.region
  ip_cidr_range            = "10.10.0.0/24"
  network                  = var.vpc_id
  private_ip_google_access = true
}


resource "google_compute_address" "psc_address" {
  project      = var.project_id
  name         = "psc-address-databricks-${var.region}"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.psc.id
}

resource "google_compute_forwarding_rule" "psc_endpoint" {
      depends_on = [
    google_compute_address.psc_address
  ]
  project               = var.project_id
  region                = var.region
  name                  = "plproxy-psc-endpoint-${var.region}"
  target                = var.psc_endpoint
  network               = var.vpc_self_link
  ip_address            = google_compute_address.psc_address.id
  load_balancing_scheme = ""
}

resource "google_compute_address" "psc_address_rest" {
  project      = var.project_id
  name         = "psc-address-databricks-rest-${var.region}"
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.psc.id
}

resource "google_compute_forwarding_rule" "psc_endpoint_rest" {
    depends_on = [
    google_compute_address.psc_address_rest
  ]
  project               = var.project_id
  region                = var.region
  name                  = "ngrok-psc-endpoint-${var.region}"
  target                = var.psc_endpoint_rest
  network               = var.vpc_self_link
  ip_address            = google_compute_address.psc_address_rest.id
  load_balancing_scheme = ""
}


