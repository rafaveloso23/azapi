output "random_suffix" {
  value       = local.rg_exists ? random_string.sufixo[0].result : null
  description = "Sufixo aleatório, só existe se o RG também existir"
}
output "azurerm_resource_group_name" {
  value       = local.rg_exists ? "${var.azurerm_resource_group_name}${random_string.sufixo[0].result}" : var.azurerm_resource_group_name
  description = "Nome do resource group a ser importado (com random se aplicável)"
}
output "rg_exists" {
  value = local.rg_exists
}
# output "rgs" {
#   value = data.azapi_resource_list.rgs.output
# }