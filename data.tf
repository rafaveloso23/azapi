data "azurerm_client_config" "current" {}

data "azapi_resource_list" "rgs" {
  type                   = "Microsoft.Resources/resourceGroups@2021-04-01"
  parent_id              = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  response_export_values = ["*"]
}


