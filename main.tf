data "azapi_resource_list" "listSubnetsByVnet" {
  type                   = "Microsoft.Network/virtualNetworks/subnets@2021-02-01"
  parent_id              = "/subscriptions/cc323661-bdfb-4e37-8224-b9f41308d182/resourceGroups/rg-aks-example/providers/Microsoft.Network/virtualNetworks/vnet-hub"
  response_export_values = ["*"]
}

# output "listSubnetsByVnet" {
#   value = data.azapi_resource_list.listSubnetsByVnet.output
# }

# data "azapi_resource_list" "listSubnetsByVnetusage" {
#   type                   = "Microsoft.Network/virtualNetworks@2021-02-01/usages"
#   parent_id              = "/subscriptions/cc323661-bdfb-4e37-8224-b9f41308d182/resourceGroups/rg-aks-example/providers/Microsoft.Network/virtualNetworks/vnet-hub"
#   response_export_values = ["*"]
# }

resource "azapi_resource_action" "vnet_usages" {
  type                   = "Microsoft.Network/virtualNetworks@2024-05-01"
  resource_id            = "/subscriptions/cc323661-bdfb-4e37-8224-b9f41308d182/resourceGroups/rg-aks-example/providers/Microsoft.Network/virtualNetworks/vnet-hub"
  action                 = "usages"
  method                 = "GET"
  response_export_values = ["*"]
}

# output "test_vnet_usages" {
#   value = azapi_resource_action.vnet_usages.output
# }

# Lógica principal: usar VNet como fonte de subnets e usages para validar disponibilidade
locals {
  # 1. Todas as subnets da VNet (fonte principal)
  all_subnets_from_vnet = [
    for subnet in data.azapi_resource_list.listSubnetsByVnet.output.value :
    {
      name = subnet.name
      id   = subnet.id
      addressPrefix = subnet.properties.addressPrefix
    }
  ]
  
  # 2. Mapa de usages por subnet (apenas para validação de IPs disponíveis)
  usage_map = {
    for usage in azapi_resource_action.vnet_usages.output.value :
    basename(usage.id) => {
      current_value = usage.currentValue
      limit         = usage.limit
      available     = usage.limit - usage.currentValue
      has_available_ips = usage.limit > usage.currentValue
    }
  }
  
  # 3. Comparação e análise das subnets
  subnet_analysis = [
    for subnet in local.all_subnets_from_vnet :
    {
      name = subnet.name
      addressPrefix = subnet.addressPrefix
      has_usage_info = contains(keys(local.usage_map), subnet.name)
      current_usage = contains(keys(local.usage_map), subnet.name) ? local.usage_map[subnet.name].current_value : 0
      limit = contains(keys(local.usage_map), subnet.name) ? local.usage_map[subnet.name].limit : null
      available_ips = contains(keys(local.usage_map), subnet.name) ? local.usage_map[subnet.name].available : null
      is_available = contains(keys(local.usage_map), subnet.name) ? local.usage_map[subnet.name].has_available_ips : true
    }
  ]
  
  # 4. Separar subnets disponíveis das cheias
  available_subnets_with_ips = [
    for subnet in local.subnet_analysis :
    subnet.name
    if subnet.is_available == true
  ]
  
  # 5. Subnets sem IPs disponíveis (cheias)
  full_subnets_without_ips = [
    for subnet in local.subnet_analysis :
    subnet.name
    if subnet.is_available == false
  ]
}

# Outputs principais
output "subnets_disponiveis" {
  description = "Subnets que têm IPs disponíveis para uso"
  value = local.available_subnets_with_ips
}

output "subnets_cheias" {
  description = "Subnets que não têm IPs disponíveis (cheias)"
  value = local.full_subnets_without_ips
}

# Output detalhado: comparação completa entre VNet e usages
output "subnet_comparison" {
  description = "Análise detalhada de todas as subnets"
  value = local.subnet_analysis
}

# Outputs de resumo
output "resumo_subnets" {
  value = {
    total_subnets = length(local.all_subnets_from_vnet)
    subnets_disponiveis = length(local.available_subnets_with_ips)
    subnets_cheias = length(local.full_subnets_without_ips)
    subnets_com_usage_info = length(keys(local.usage_map))
  }
}