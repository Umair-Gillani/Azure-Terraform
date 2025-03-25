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

  custom_data = base64encode(<<EOF
#!/bin/bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Check version
kubectl version --client

# Bash completion
sudo apt install -y bash-completion
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc
EOF
  )
  tags = var.tags
}

