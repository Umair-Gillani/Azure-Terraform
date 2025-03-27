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
# ############################################
# resource "azurerm_public_ip" "nat_gw_pip" {
#   name                = "${var.vnet_name}-nat-pip"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   tags                = var.tags
# }

# resource "azurerm_nat_gateway" "nat_gw" {
#   name                = "${var.vnet_name}-nat-gateway"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   sku_name            = "Standard"
#   tags                = var.tags
# }

# resource "azurerm_nat_gateway_public_ip_association" "nat_assoc" {
#   nat_gateway_id       = azurerm_nat_gateway.nat_gw.id
#   public_ip_address_id = azurerm_public_ip.nat_gw_pip.id
# }

# resource "azurerm_subnet_nat_gateway_association" "db_nat_assoc" {
#   subnet_id      = azurerm_subnet.db.id
#   nat_gateway_id = azurerm_nat_gateway.nat_gw.id
# }

# resource "azurerm_subnet_nat_gateway_association" "aks_nat_assoc" {
#   subnet_id      = azurerm_subnet.aks.id
#   nat_gateway_id = azurerm_nat_gateway.nat_gw.id
# }







############################################
# 4) Create an NSG for Private Subnets
############################################

# 🧠 Summary (to remember easily)
# Port	Use Case	Add Rule?
# 22	SSH (Linux)	✅ Yes
# 3389	RDP (Windows)	✅ Optional using template
# 80	HTTP Website	✅ Yes
# 443	HTTPS Website	✅ Yes
# 8080	Custom App/Debug	✅ Optional using template
# Any	Others	❌ Denied by default (if deny rule added)

#########################################################
#  Create an NSG for Public Subnet (10.17.2.0/24) Subnets
#########################################################
# resource "azurerm_network_security_group" "public_nsg" {
#   name                = "${var.public_subnet_name}-nsg"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
# }

# # ✅ Allow SSH (port 22) from Internet → Public Subnet
# resource "azurerm_network_security_rule" "allow_ssh" {
#   name                        = "Allow-SSH"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "22"
#   source_address_prefix       = "0.0.0.0/0"
#   destination_address_prefix  = local.public_subnet_cidr
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.public_nsg.name
# }

# # ✅ Allow HTTP (80) from Internet
# resource "azurerm_network_security_rule" "allow_http" {
#   name                        = "Allow-HTTP"
#   priority                    = 110
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "80"
#   source_address_prefix       = "0.0.0.0/0"
#   destination_address_prefix  = local.public_subnet_cidr
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.public_nsg.name
# }

# # ✅ Allow HTTPS (443) from Internet
# resource "azurerm_network_security_rule" "allow_https" {
#   name                        = "Allow-HTTPS"
#   priority                    = 120
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "443"
#   source_address_prefix       = "0.0.0.0/0"
#   destination_address_prefix  = local.public_subnet_cidr
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.public_nsg.name
# }

# # ❌ DENY: Block ALL other public access (use only when needed)
# # ⚠️ This will block everything else except allowed ports above
# resource "azurerm_network_security_rule" "deny_all_other" {
#   name                        = "Deny-All-Other-Internet"
#   priority                    = 200
#   direction                   = "Inbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "Internet"
#   destination_address_prefix  = "*"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.public_nsg.name
# }

# # Allow outbound to Internet
# resource "azurerm_network_security_rule" "public_allow_outbound_internet" {
#   name                        = "AllowInternetOutBound"
#   priority                    = 1000
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "Internet"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.public_nsg.name
# }

# # Allow AzureCloud traffic (internal Azure services)
# resource "azurerm_network_security_rule" "public_allow_azure_services" {
#   name                        = "AllowAzureCloud"
#   priority                    = 1010
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "AzureCloud"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.public_nsg.name
# }


# # 🧩 TEMPLATE: Use this format to allow future custom ports like 8080 or 3389
# # ✨ Just copy this block, change '8080' to any port, and update the name + priority
# # Example: for RDP access → use 3389

# # resource "azurerm_network_security_rule" "allow_custom_port" {
# #   name                        = "Allow-Custom-Port-8080"
# #   priority                    = 130
# #   direction                   = "Inbound"
# #   access                      = "Allow"
# #   protocol                    = "Tcp"
# #   source_port_range           = "*"
# #   destination_port_range      = "8080"
# #   source_address_prefix       = "0.0.0.0/0"
# #   destination_address_prefix  = local.public_subnet_cidr
# #   resource_group_name         = var.resource_group_name
# #   network_security_group_name = azurerm_network_security_group.public_nsg.name
# # }

# # 🔗 Associate NSG with Public Subnet
# resource "azurerm_subnet_network_security_group_association" "public_assoc" {
#   subnet_id                 = azurerm_subnet.public.id
#   network_security_group_id = azurerm_network_security_group.public_nsg.id
# }





# #########################################################
# #  Create an NSG for AKS Subnet (10.17.1.0/24) Subnets
# #########################################################
# resource "azurerm_network_security_group" "aks_nsg" {
#   name                = "${var.aks_subnet_name}-nsg"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
# }

# # Bastion/Public Subnet → AKS (API server)
# resource "azurerm_network_security_rule" "public_to_aks_api" {
#   name                        = "AllowPublicToAKSAPI"
#   priority                    = 105
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "443"
#   source_address_prefix       = local.public_subnet_cidr
#   destination_address_prefix  = local.cluster_subnet_cidr
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.aks_nsg.name
# }

# # DB → AKS (all ports)
# resource "azurerm_network_security_rule" "db_to_aks" {
#   name                        = "DBToAKS"
#   priority                    = 110
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = local.db_subnet_cidr
#   destination_address_prefix  = local.cluster_subnet_cidr
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.aks_nsg.name
# }

# # Deny everything else to AKS
# resource "azurerm_network_security_rule" "deny_other_to_aks" {
#   name                        = "DenyOtherToAKS"
#   priority                    = 4000
#   direction                   = "Inbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = local.cluster_subnet_cidr
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.aks_nsg.name
# }

# # Allow outbound to Internet
# resource "azurerm_network_security_rule" "aks_allow_outbound_internet" {
#   name                        = "AllowInternetOutBound"
#   priority                    = 1000
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "Internet"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.aks_nsg.name
# }

# # Allow AzureCloud traffic (internal Azure services)
# resource "azurerm_network_security_rule" "aks_allow_azure_services" {
#   name                        = "AllowAzureCloud"
#   priority                    = 1010
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "AzureCloud"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.aks_nsg.name
# }



# resource "azurerm_subnet_network_security_group_association" "aks_assoc" {
#   subnet_id                 = azurerm_subnet.aks.id
#   network_security_group_id = azurerm_network_security_group.aks_nsg.id
# }





# #########################################################
# #  Create an NSG for DB Subnet (10.17.3.0/24) Subnets
# #########################################################
# resource "azurerm_network_security_group" "db_nsg" {
#   name                = "${var.db_subnet_name}-nsg"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
# }

# # AKS → DB
# resource "azurerm_network_security_rule" "aks_to_db" {
#   name                        = "AKSToDB"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = local.cluster_subnet_cidr
#   destination_address_prefix  = local.db_subnet_cidr
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.db_nsg.name
# }

# # Public Subnet → DB (MySQL Port)
# resource "azurerm_network_security_rule" "public_to_db_mysql" {
#   name                        = "AllowPublicToMySQL"
#   priority                    = 105
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "3306"
#   source_address_prefix       = local.public_subnet_cidr
#   destination_address_prefix  = local.db_subnet_cidr
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.db_nsg.name
# }

# # Deny everything else to DB
# resource "azurerm_network_security_rule" "deny_other_to_db" {
#   name                        = "DenyOtherToDB"
#   priority                    = 4000
#   direction                   = "Inbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = local.db_subnet_cidr
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.db_nsg.name
# }

# # Allow outbound to Internet
# resource "azurerm_network_security_rule" "db_allow_outbound_internet" {
#   name                        = "AllowInternetOutBound"
#   priority                    = 1000
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "Internet"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.db_nsg.name
# }

# # Allow AzureCloud traffic (internal Azure services)
# resource "azurerm_network_security_rule" "db_allow_azure_services" {
#   name                        = "AllowAzureCloud"
#   priority                    = 1010
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "AzureCloud"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.db_nsg.name
# }


# resource "azurerm_subnet_network_security_group_association" "db_assoc" {
#   subnet_id                 = azurerm_subnet.db.id
#   network_security_group_id = azurerm_network_security_group.db_nsg.id
# }











################################################################################
################################################################################

############################################
# 4) (Optional) Create an NSG for Private Subnets
############################################
# resource "azurerm_network_security_group" "aks_nsg" {
#   name                = "${var.aks_subnet_name}-nsg"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
# }

# # NEW: allow private subnets to talk to each other
# resource "azurerm_network_security_rule" "allow_private_intra" {
#   name                        = "Allow-Private-Subnets"
#   priority                    = 150
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = var.vnet_cidr
#   destination_address_prefix  = var.vnet_cidr
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.aks_nsg.name
# }

# resource "azurerm_network_security_rule" "allow_bastion_to_aks" {
#   name                        = "AllowBastionToAKS"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"

#   source_address_prefix       = local.public_subnet_cidr
#   destination_address_prefix  = local.cluster_subnet_cidr

#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.aks_nsg.name
# }

# ############################################
# # NSG Association
# ############################################

# # Attach NSG to the private subnets
# resource "azurerm_subnet_network_security_group_association" "aks_subnet_assoc" {
#   subnet_id                 = azurerm_subnet.aks.id
#   network_security_group_id = azurerm_network_security_group.aks_nsg.id
# }

# resource "azurerm_subnet_network_security_group_association" "db_subnet_assoc" {
#   subnet_id                 = azurerm_subnet.db.id
#   network_security_group_id = azurerm_network_security_group.aks_nsg.id
# }



################################################################################
################################################################################


