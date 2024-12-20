terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.50.0"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "databricks" {
  alias                  = "accounts"
  host                   = "https://accounts.gcp.databricks.com"
  google_service_account = var.google_service_account
  account_id             = var.account_id

}

provider "databricks" {
  alias         = "workspace"
  host          = var.databricks_host
  client_id     = var.client_id
  client_secret = var.client_secret
  account_id    = var.account_id
}
