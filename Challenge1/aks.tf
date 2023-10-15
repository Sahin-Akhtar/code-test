resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.kpmg-rg.location
  name                = "k8s-kpmg-code-test"
  resource_group_name = azurerm_resource_group.kpmg-rg.name
  dns_prefix          = "dns-k8s-kpmg-code-test"
  sku_tier           = "Free"
  kubernetes_version = "1.25.11"

  identity {
    type = "SystemAssigned"
  }
  
  
  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
    vnet_subnet_id = azurerm_subnet.app.id
  }
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "memorynode" {
  name                  = "memorynode"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_B2ms"

  node_count            = 1

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "balancednode" {
  name                  = "balancednode"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_D2_v2"
  node_count            = 1

  tags = {
    Environment = "Production"
  }
}



