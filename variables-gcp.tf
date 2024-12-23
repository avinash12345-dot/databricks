##variables for vpc##
variable "network" {
  type        = string
  description = "Name of the network to create"
}

variable "project_id" {
  type        = string
  description = "The id of the project"
}

variable "subnets" {
  description = "The subnets to create in the net project"
  type = map(object({
    ip_cidr_range = string
    name          = string
    description   = string
    region        = string
    secondary_ip_range = list(object({
      range_name    = string
      ip_cidr_range = string
    }))
  }))
  default = {}
}

variable "router" {
  type        = string
  description = "name of the router"
}

##variables for routes##

variable "project_id" {
  description = "The ID of the project where the routes will be created"
  type        = string
}

variable "network" {
  description = "The name of the network where routes will be created"
  type        = string
}
variable "routes" {
  type        = list(map(string))
  description = "List of routes being created in this VPC"
  default     = []
}

##variables for metastore##
variable "grant" {
  type        = list(any)
  description = "permissions"
  default     = []
}

variable "region" {
  type        = string
  description = "Databricks workspace region"
}

variable "account_id" {
  type        = string
  description = "databricks AccountID"
  default     = ""
}

variable "google_service_account" {
  type        = string
  description = "google_service_account"

}

variable "databricks_host" {
  type        = string
  description = "databricks_host"

}

variable "workspace_id" {
  type        = string
  description = "workspace_id"

}

variable "client_id" {
  type        = string
  description = "client id"
}

variable "client_secret" {
  type        = string
  description = "client secret"
}

##variables for schema##
variable "account_id" {
  type        = string
  description = "databricks AccountID"
  default     = "f734d7f1-2194-40eb-bb2d-2dfbd9c98372"
}

variable "project_id" {
  type        = string
  description = "The id of the project"
}

variable "region" {
  type        = string
  description = "Databricks workspace region"
}

variable "catalog_id" {
    type = string
    description = "Catalog id to associate with the schema"
  
}

variable "databricks_sa_email" {
    type = string
    description = "Databricks SA email"
}

variable "schema" {
  type        = any
  description = "schema details"
}

variable "schema_owner" {
  type        = string
  description = "schema owner"
}

variable "client_id" {
  type        = string
  description = "client id"
}

variable "client_secret" {
  type        = string
  description = "client secret"
  sensitive = true
}

variable "workspace_url" {
  type = string
  description = "Workspace URL"
}

variable "databricks_impersonators" {
  type        = list(string)
  description = "The users that get access to impersonate Databricks SA"
  default     = []
}

variable "project_id" {
  type        = string
  description = "The id of the project"
}

variable "region" {
  type        = string
  description = "Databricks workspace region"
}

variable "account_id" {
  type        = string
  description = "databricks AccountID"
  default     = "f734d7f1-2194-40eb-bb2d-2dfbd9c98372"
}

variable "spark_version" {
  type    = string
  default = "13.3.x-scala2.12"
}

variable "runtime_engine" {
  type    = string
  default = "PHOTON"
}

variable "driver_node_type_id" {
  type    = string
  default = "n2-highmem-8"
}

variable "node_type_id" {
  type    = string
  default = "n2-highmem-8"
}

variable "user1" {
  type        = list(string)
  description = "The user that get access to workspace"
  default     = []
}

variable "workspace_name" {
  type        = string
  description = "Databricks workspace name"
}

variable "private_access_settings_name" {
  type        = string
  description = "private connection"
}

variable "record_set_workspace_url" {
  type        = string
  description = "DNS ID"
}

variable "record_set_workspace_dp" {
  type        = string
  description = "DNS DP ID"
}

variable "vpc_endpoint_name_frontend" {
  type        = string
  description = "VPC endpoint frontend"
}

variable "vpc_endpoint_name_backend" {
  type        = string
  description = "VPC endpoint backend"
}

variable "endpoint_region" {
  type        = string
  description = "endpoint region"
}

variable "network_name" {
  type        = string
  description = "databricks network name"
}

variable "vpc_name" {
  type        = string
  description = "vpc name"
}

variable "vpc_id" {
  type        = string
  description = "vpc_id"
}

variable "vpc_self_link" {
  type        = string
  description = "vpc_self_link"
}

variable "subnet_name" {
  type        = string
  description = "subnet name"
}

variable "subnet_region" {
  type        = string
  description = "subnet_region name"
}

variable "pod_ip_range_name" {
  type        = string
  description = "pod_ip_range name"
}

variable "service_ip_range_name" {
  type        = string
  description = "service_ip_range name"
}

variable "metastore_id" {
  type        = string
  description = "metastore_id"
}

variable "bucket_name" {
  type        = string
  description = "name of the bucket"
}

variable "storage_credential" {
  type        = string
  description = "name of the storage credential"
}

variable "external_location" {
  type        = string
  description = "name of the external_location"
}

variable "catalog_name" {
  type        = string
  description = "name of the catalog"
}

variable "schema" {
  type        = map(any)
  description = "schema details"
}

variable "grant_development" {
  type        = list(any)
  description = "permissions for development catalog"
  default     = []
}

variable "psc_endpoint_rest" {
  type        = string
  description = "backend endpoint"
}

variable "psc_endpoint" {
  type        = string
  description = "frontend endpoint"
}

variable "location_principal" {
  type        = string
  description = "service principal"
}

variable "client_id" {
  type        = string
  description = "client id"
}

variable "client_secret" {
  type        = string
  description = "client secret"
}


variable "catalog_owner" {
  type        = string
  description = "service principal"
}

variable "schema_owner" {
  type        = string
  description = "schema owner"
}


