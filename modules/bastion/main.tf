######################################################
# modules/bastion/main.tf
# Provides a Bastion Host in a specified subnet
######################################################

# -----------------------------------------------------
# 1) Public IP for Bastion
# -----------------------------------------------------
resource "azurerm_public_ip" "this" {
  name                = "${var.bastion_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Basic"
  tags                = var.tags
}

# -----------------------------------------------------
# 2) Network Interface for Bastion VM
# -----------------------------------------------------
resource "azurerm_network_interface" "bastion_nic" {
  name                = "${var.bastion_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id    # <-- Use the subnet_id passed from root module
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }

  tags = var.tags
}

# -----------------------------------------------------
# 3) Linux VM for Bastion
# -----------------------------------------------------
resource "azurerm_linux_virtual_machine" "this" {
  name                = var.bastion_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.bastion_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_key
  }

  tags = var.tags
}

# -----------------------------------------------------
# 4) Outputs
# -----------------------------------------------------
output "public_ip" {
  description = "Public IP of Bastion Host"
  value       = azurerm_public_ip.this.ip_address
}

output "bastion_vm_name" {
  description = "Name of the Bastion VM"
  value       = azurerm_linux_virtual_machine.this.name
}
