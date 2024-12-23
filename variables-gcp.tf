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
