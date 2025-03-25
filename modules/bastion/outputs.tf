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
