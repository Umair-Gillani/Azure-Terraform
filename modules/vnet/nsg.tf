#########################################################
# 1) NSG + Rules for Public Subnet (10.17.2.0/24)
#########################################################

resource "azurerm_network_security_group" "public_nsg" {
  name                = "${var.public_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# ✅ Allow SSH (port 22) from Internet → Public Subnet
resource "azurerm_network_security_rule" "public_allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = local.public_subnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public_nsg.name
}

# ✅ Allow HTTP (80) from Internet
resource "azurerm_network_security_rule" "public_allow_http" {
  name                        = "Allow-HTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = local.public_subnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public_nsg.name
}

# ✅ Allow HTTPS (443) from Internet
resource "azurerm_network_security_rule" "public_allow_https" {
  name                        = "Allow-HTTPS"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "0.0.0.0/0"
  destination_address_prefix  = local.public_subnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public_nsg.name
}

# ❌ DENY: Block ALL other inbound public access
resource "azurerm_network_security_rule" "public_deny_all_other" {
  name                        = "Deny-All-Other-Internet"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public_nsg.name
}

# Allow outbound to Internet
resource "azurerm_network_security_rule" "public_allow_outbound_internet" {
  name                        = "AllowInternetOutBound"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public_nsg.name
}

# Allow AzureCloud traffic (internal Azure services)
resource "azurerm_network_security_rule" "public_allow_azure_services" {
  name                        = "AllowAzureCloud"
  priority                    = 1010
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.public_nsg.name
}

# Associate NSG with Public Subnet
resource "azurerm_subnet_network_security_group_association" "public_assoc" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}


#########################################################
# 2) NSG + Rules for AKS Subnet (10.17.1.0/24)
#########################################################

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.aks_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Bastion/Public Subnet → AKS (API server)
resource "azurerm_network_security_rule" "aks_public_to_aks_api" {
  name                        = "AllowPublicToAKSAPI"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = local.public_subnet_cidr
  destination_address_prefix  = local.cluster_subnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# DB → AKS (all ports)
resource "azurerm_network_security_rule" "aks_db_to_aks" {
  name                        = "DBToAKS"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = local.db_subnet_cidr
  destination_address_prefix  = local.cluster_subnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# Deny everything else to AKS
resource "azurerm_network_security_rule" "aks_deny_other_to_aks" {
  name                        = "DenyOtherToAKS"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = local.cluster_subnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# Allow outbound to Internet
resource "azurerm_network_security_rule" "aks_allow_outbound_internet" {
  name                        = "AllowInternetOutBound"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# Allow AzureCloud traffic (internal Azure services)
resource "azurerm_network_security_rule" "aks_allow_azure_services" {
  name                        = "AllowAzureCloud"
  priority                    = 1010
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# Associate NSG with the AKS Subnet
resource "azurerm_subnet_network_security_group_association" "aks_assoc" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}


#########################################################
# 3) NSG + Rules for DB Subnet (10.17.3.0/24)
#########################################################

resource "azurerm_network_security_group" "db_nsg" {
  name                = "${var.db_subnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# AKS → DB
resource "azurerm_network_security_rule" "db_aks_to_db" {
  name                        = "AKSToDB"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = local.cluster_subnet_cidr
  destination_address_prefix  = local.db_subnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

# Public Subnet → DB (MySQL Port)
resource "azurerm_network_security_rule" "db_public_to_db_mysql" {
  name                        = "AllowPublicToMySQL"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = local.public_subnet_cidr
  destination_address_prefix  = local.db_subnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

# Deny everything else to DB
resource "azurerm_network_security_rule" "db_deny_other_to_db" {
  name                        = "DenyOtherToDB"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = local.db_subnet_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

# Allow outbound to Internet
resource "azurerm_network_security_rule" "db_allow_outbound_internet" {
  name                        = "AllowInternetOutBound"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

# Allow AzureCloud traffic (internal Azure services)
resource "azurerm_network_security_rule" "db_allow_azure_services" {
  name                        = "AllowAzureCloud"
  priority                    = 1010
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

# Associate NSG with DB Subnet
resource "azurerm_subnet_network_security_group_association" "db_assoc" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}
