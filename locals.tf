locals {
  # Realiza um decode da chamada api, retornando uma lista de rg e parametros
  rg = try(jsondecode(data.azapi_resource_list.rgs.output).value, [])

  # Valida a existencia de rg, consultando o resultado da chamada api, retorando true ou false
  rg_exists = length([
    for rg in local.rg : rg
    if lower(rg.name) == lower(var.azurerm_resource_group_name)
  ]) > 0
}