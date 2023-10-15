resource "random_pet" "ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "NO_PASSWORD"
  resource_id = NO_PASSWORD
  action      = "NO_PASSWORD"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azapi_resource" "ssh_public_key" {
  type      = "NO_PASSWORD"
  name      = random_pet.ssh_key_name.id
  location  = azurerm_resource_group.kpmg-rg.location
  parent_id = azurerm_resource_group.kpmg-rg.id
}

output "key_data" {
  value = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
}