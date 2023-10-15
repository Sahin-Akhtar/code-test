resource "azurerm_network_security_group" "dbnsg" {
  name                = "dbnsg"
  location            = "${azurerm_resource_group.kpmg-rg.location}"
  resource_group_name = "${azurerm_resource_group.kpmg-rg.name}"

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "10.30.2.0/24"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.30.2.0/24"
  }
}


resource "azurerm_mssql_server" "msql_server" {
  name                         = "kpmgsqlserver"
  resource_group_name          = azurerm_resource_group.kpmg-rg.name
  location                     = azurerm_resource_group.kpmg-rg.location
  version                      = "12.0"
  administrator_login          = var.dbusername
  administrator_login_password = var.dbpassword
}

resource "azurerm_mssql_database" "kpmg-mssql" {
  name      = "kpmgdb"
  server_id = azurerm_mssql_server.msql_server.id
}

resource "azurerm_storage_account" "kpmg_sag" {
  name                     = "storagekpmg"
  resource_group_name      = azurerm_resource_group.kpmg-rg.name
  location                 = azurerm_resource_group.kpmg-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_database_extended_auditing_policy" "kpmg-audit" {
  database_id                             = azurerm_mssql_database.kpmg-mssql.id
  storage_endpoint                        = azurerm_storage_account.kpmg_sag.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.kpmg_sag.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 14
}


resource "azurerm_private_endpoint" "plink" {
  name                = "sqlprivate-endpoint"
  location            = azurerm_resource_group.kpmg-rg.location
  resource_group_name = azurerm_resource_group.kpmg-rg.name
  subnet_id           = azurerm_subnet.db.id

  private_service_connection {
    name                           = "privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.msql_server.id
    subresource_names              = [ "sqlServer" ]
    is_manual_connection           = false
  }
} 
resource "azurerm_private_dns_zone" "plink_dns_private_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.kpmg-rg.name
}


resource "azurerm_private_dns_a_record" "private_endpoint_a_record" {
  name                = azurerm_mssql_server.msql_server.name
  zone_name           = azurerm_private_dns_zone.plink_dns_private_zone.name
  resource_group_name = azurerm_resource_group.kpmg-rg.name
  ttl                 = 300
  records             = ["10.0.180.17"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "zone_to_vnet_link" {
  name                  = "dns_zone_link"
  resource_group_name   = azurerm_resource_group.kpmg-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.plink_dns_private_zone.name
  virtual_network_id    = azurerm_virtual_network.kpmg-vnet.id
}
