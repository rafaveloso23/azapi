# random só vai ser criado quando local.rg_exists == true
resource "random_string" "sufixo" {
  count   = local.rg_exists ? 1 : 0
  length  = 4
  upper   = false
  lower   = true
  special = false
}