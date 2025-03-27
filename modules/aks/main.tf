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
    vm_size             = var.vm_size
    vnet_subnet_id      = var.vnet_subnet_id
    enable_auto_scaling = true
    min_count           = var.min_count
    max_count           = var.max_count
    
    # orchestrator_version= "auto"       #  specify k8s version for production environment or azure will automatically pick the latest version

####  terraform import azurerm_kubernetes_cluster.this /subscriptions/<sub_id>/resourceGroups/<rg>/providers/Microsoft.ContainerService/managedClusters/<cluster_name>


  }


  network_profile {
    network_plugin     = "azure"  # Azure CNI (Advanced networking) is being used. FOR BASIC => network_plugin = "kubenet"
    load_balancer_sku  = "standard"  # changing it to "standard" can =>  allow authorized IP ranges and better security.
    service_cidr       = "10.2.0.0/16"
    dns_service_ip     = "10.2.0.10"
    outbound_type      = "loadBalancer"  # k8s created LB is used for outbound traffic of backend nodepool  

    # docker_bridge_cidr = "172.17.0.1/16"   # `docker_bridge_cidr` has been deprecated 
    # We do not create an external LB. This is an internal cluster usage only.
  }
  private_cluster_enabled = true 

  tags = var.tags
}

# Grant AKS’s managed identity pull/push to ACR
resource "azurerm_role_assignment" "aks_acr" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.identity[0].principal_id
}


