resource "azurerm_network_security_group" "webnsg" {
  name                = "web_nsg"
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
    destination_address_prefix = "*"
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
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "publicIPForLB"
  location            = azurerm_resource_group.kpmg-rg.location
  resource_group_name = azurerm_resource_group.kpmg-rg.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = "loadBalancer"
  location            = azurerm_resource_group.kpmg-rg.location
  resource_group_name = azurerm_resource_group.kpmg-rg.name

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface" "app_nic" {
  count               = 2
  name                = "acctni${count.index}"
  location            = azurerm_resource_group.kpmg-rg.location
  resource_group_name = azurerm_resource_group.kpmg-rg.name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_availability_set" "avset" {
  name                         = "avset"
  location                     = azurerm_resource_group.kpmg-rg.location
  resource_group_name          = azurerm_resource_group.kpmg-rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                 = 2
  name                  = "webvm${count.index}"
  location              = azurerm_resource_group.kpmg-rg.location
  availability_set_id   = azurerm_availability_set.avset.id
  resource_group_name   = azurerm_resource_group.kpmg-rg.name
  network_interface_ids = [azurerm_network_interface.app_nic[count.index].id]
  size                  = "Standard_DS1_v2"
   source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  admin_ssh_key {
    username   = var.username
    public_key = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "myosdisk${count.index}"
  }

  computer_name  = "linux"
  admin_username = var.username
}

