# Create a resource group
resource "azurerm_resource_group" "kpmg-rg" {
  name     = "kpmg-rg-code-test"
  location = "East US2"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "kpmg-vnet" {
  name                = "kpmg-network"
  resource_group_name = azurerm_resource_group.kpmg-rg.name
  location            = azurerm_resource_group.kpmg-rg.location
  address_space       = ["10.30.0.0/16"]
}

resource "azurerm_subnet" "web" {
 name                 = "websubnet"
 resource_group_name  = azurerm_resource_group.kpmg-rg.name
 virtual_network_name = azurerm_virtual_network.kpmg-vnet.name
 address_prefixes       = ["10.30.1.0/24"]
}

resource "azurerm_subnet" "app" {
 name                 = "appsubnet"
 resource_group_name  = azurerm_resource_group.kpmg-rg.name
 virtual_network_name = azurerm_virtual_network.kpmg-vnet.name
 address_prefixes       = ["10.30.2.0/24"]
  
 enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "db" {
 name                 = "dbsubnet"
 resource_group_name  = azurerm_resource_group.kpmg-rg.name
 virtual_network_name = azurerm_virtual_network.kpmg-vnet.name
 address_prefixes       = ["10.30.3.0/24"]
 
 enforce_private_link_endpoint_network_policies = true
}
