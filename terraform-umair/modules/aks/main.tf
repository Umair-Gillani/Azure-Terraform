resource "azurerm_kubernetes_cluster" "this" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  # Attach ACR permissions
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                = "agentpool"
    node_count          = var.default_node_count
    vm_size             = "Standard_B2s"
    vnet_subnet_id      = var.vnet_subnet_id
    enable_auto_scaling = true
    min_count           = var.min_count
    max_count           = var.max_count
    orchestrator_version= "auto"
  }


  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "basic"
    service_cidr       = "10.2.0.0/16"
    dns_service_ip     = "10.2.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    # We do not create an external LB. This is an internal cluster usage only.
  }

  tags = var.tags
}

# Grant AKS’s managed identity pull/push to ACR
resource "azurerm_role_assignment" "aks_acr" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.identity[0].principal_id
}


