##used to register the networks created in gcp in databricks
resource "databricks_mws_vpc_endpoint" "backend_rest_vpce1" {
  provider = databricks.mws
  account_id        = var.account_id
  vpc_endpoint_name = var.vpc_endpoint_name_backend
  gcp_vpc_endpoint_info {
    project_id        = var.project_id
    psc_endpoint_name = "plproxy-psc-endpoint-us-east1"
    endpoint_region   = var.endpoint_region
  }
}

resource "databricks_mws_vpc_endpoint" "relay_vpce1" {
  provider = databricks.mws
  account_id        = var.account_id
  vpc_endpoint_name = var.vpc_endpoint_name_frontend
  gcp_vpc_endpoint_info {
    project_id        = var.project_id
    psc_endpoint_name = "ngrok-psc-endpoint-us-east1"
    endpoint_region   = var.endpoint_region
  }
}

resource "databricks_mws_networks" "this2" {
  provider     = databricks.accounts
  account_id   = var.account_id
  network_name = var.network_name
  gcp_network_info {
    network_project_id    = var.project_id
    vpc_id                = var.vpc_name
    subnet_id             = var.subnet_name
    subnet_region         = var.subnet_region
    pod_ip_range_name     = var.pod_ip_range_name
    service_ip_range_name = var.service_ip_range_name
  }
    vpc_endpoints {
    dataplane_relay = [databricks_mws_vpc_endpoint.relay_vpce1.vpc_endpoint_id]
    rest_api        = [databricks_mws_vpc_endpoint.backend_rest_vpce1.vpc_endpoint_id]
  }
}
