locals {
  schema_permissions = merge(
    [
      for schema_name, schema_permissions in var.schema :
      { for schema_permission in schema_permissions : "${schema_name}:${schema_permission.principal}" => {
        schema_name = schema_name
        schema_privileges = schema_permission.privileges
        schema_principal = schema_permission.principal
      } }
    ]...
  )
}

resource "databricks_schema" "schema" {
  for_each     = var.schema
  provider     = databricks.workspace
  owner        = var.schema_owner
  catalog_name = var.catalog_id
  name         = each.key
  comment      = "this database is managed by terraform"
  properties = {
    kind = "various"
  }
}

resource "databricks_grant" "schema_grant_databricks_sa" {
  for_each = var.schema
  provider = databricks.workspace
  schema   = databricks_schema.schema[each.key].id
  principal  = var.databricks_sa_email
  privileges = ["ALL_PRIVILEGES"]
}

resource "databricks_grant" "schema_grant" {
  for_each = local.schema_permissions
  provider = databricks.workspace
  schema = databricks_schema.schema[each.value.schema_name].id
  principal = each.value.schema_principal
  privileges = each.value.schema_privileges
}
