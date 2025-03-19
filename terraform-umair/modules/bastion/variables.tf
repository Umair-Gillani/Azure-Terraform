variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "bastion_name" {
  type        = string
  description = "Name of the Bastion host"
}

variable "vm_size" {
  type        = string
  description = "Size of the Bastion VM"
  default     = "Standard_B1s"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the Bastion host"
}

variable "ssh_key" {
  type        = string
  description = "SSH public key"
}

variable "tags" {
  type        = map(string)
  default     = {}
}

# New: The subnet_id we pass from the root module
variable "subnet_id" {
  type        = string
  description = "ID of the public subnet for Bastion"
}
