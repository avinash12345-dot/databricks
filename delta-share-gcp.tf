resource "databricks_share" "some" {
  provider = databricks.workspace
  for_each = var.shares
  name     = each.value.name
  dynamic "object" {
    for_each = each.value.objects
    content {
      name                        = object.value.name
      data_object_type            = object.value.type
      history_data_sharing_status = "ENABLED"
    }
  }
}

resource "databricks_recipient" "db2db" {
  provider = databricks.workspace
  for_each                           = var.recipients
  name                               = each.value.name
  comment                            = "made by terraform"
  authentication_type                = "DATABRICKS"
  data_recipient_global_metastore_id = each.value.metastore_id
}
