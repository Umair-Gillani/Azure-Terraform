############################################
# 1) Calculate Subnet CIDRs Dynamically
############################################
# The 'cidrsubnet' function adds extra bits to a base CIDR.
# 
# If your base VNet CIDR is /16, adding 8 bits creates a /24.
# The third argument (netnum) chooses the incremental subnet 
# (0 -> first /24, 1 -> second /24, etc.). We pick them to 
# match your requested pattern:
#   Public = 10.17.2.0/24  (netnum = 2)
#   AKS    = 10.17.1.0/24  (netnum = 1)
#   DB     = 10.17.3.0/24  (netnum = 3)
#
# For production vs. staging, just change var.vnet_cidr
# to 10.18.0.0/16 (etc.).

locals {
  # Derive /24 subnets from the base /16
  # If you want /24 subnets from a /16, that's 8 new bits 
  # (the second argument to cidrsubnet).
  public_subnet_cidr  = cidrsubnet(var.vnet_cidr, 8, 2)
  cluster_subnet_cidr = cidrsubnet(var.vnet_cidr, 8, 1)
  db_subnet_cidr      = cidrsubnet(var.vnet_cidr, 8, 3)
}

############################################
# 2) Create the VNet
############################################
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # The VNet address space is just the single base CIDR
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

############################################
# 3) Create Subnets
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
}

resource "azurerm_subnet" "db" {
  name                 = var.db_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.db_subnet_cidr]
}

############################################
# 4) (Optional) Create an NSG for AKS and a Rule
############################################
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.aks_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Example rule: allow inbound from the Public subnet (Bastion) to the AKS subnet
resource "azurerm_network_security_rule" "allow_bastion_to_aks" {
  name                        = "AllowBastionToAKS"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"

  # Source is the Public Subnet range
  source_address_prefix       = local.public_subnet_cidr
  # Destination is the AKS Subnet range
  destination_address_prefix  = local.cluster_subnet_cidr

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# Attach the NSG to the AKS Subnet
resource "azurerm_subnet_network_security_group_association" "aks_subnet_assoc" {
  subnet_id                 = azurerm_subnet.aks.id
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
