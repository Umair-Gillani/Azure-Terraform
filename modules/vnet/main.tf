############################################
# 1) Calculate Subnet CIDRs Dynamically
############################################
locals {
  public_subnet_cidr  = cidrsubnet(var.vnet_cidr, 8, 2)
  cluster_subnet_cidr = cidrsubnet(var.vnet_cidr, 8, 1)
  db_subnet_cidr      = cidrsubnet(var.vnet_cidr, 8, 3)
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

############################################
# 2) Create Subnets
############################################
resource "azurerm_subnet" "public" {
  name                 = var.public_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.public_subnet_cidr]
}

resource "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.cluster_subnet_cidr]
  
  # New: service endpoints for azure
  service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
}

resource "azurerm_subnet" "db" {
  name                 = var.db_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.db_subnet_cidr]

  # New: service endpoints for azure
  service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
}

############################################
# 3) NAT Gateway for Private Subnets
############################################
resource "azurerm_public_ip" "nat_gw_pip" {
  name                = "${var.vnet_name}-nat-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "nat_gw" {
  name                = "${var.vnet_name}-nat-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gw.id
  public_ip_address_id = azurerm_public_ip.nat_gw_pip.id
}

resource "azurerm_subnet_nat_gateway_association" "db_nat_assoc" {
  subnet_id      = azurerm_subnet.db.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}

resource "azurerm_subnet_nat_gateway_association" "aks_nat_assoc" {
  subnet_id      = azurerm_subnet.aks.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}

############################################
# 4) (Optional) Create an NSG for Private Subnets
############################################
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.aks_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# NEW: allow private subnets to talk to each other
resource "azurerm_network_security_rule" "allow_private_intra" {
  name                        = "Allow-Private-Subnets"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.vnet_cidr
  destination_address_prefix  = var.vnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

resource "azurerm_network_security_rule" "allow_bastion_to_aks" {
  name                        = "AllowBastionToAKS"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"

  source_address_prefix       = local.public_subnet_cidr
  destination_address_prefix  = local.cluster_subnet_cidr

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# Attach NSG to the private subnets
resource "azurerm_subnet_network_security_group_association" "aks_subnet_assoc" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "db_subnet_assoc" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

############################################
# 5) Outputs
############################################
output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.this.name
}

output "public_subnet_name" {
  description = "Public Subnet name"
  value       = azurerm_subnet.public.name
}

output "aks_subnet_name" {
  description = "AKS Subnet name"
  value       = azurerm_subnet.aks.name
}

output "db_subnet_name" {
  description = "DB Subnet name"
  value       = azurerm_subnet.db.name
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = azurerm_subnet.public.id
}

output "aks_subnet_id" {
  description = "AKS Subnet ID"
  value       = azurerm_subnet.aks.id
}

output "db_subnet_id" {
  description = "DB Subnet ID"
  value       = azurerm_subnet.db.id
}
