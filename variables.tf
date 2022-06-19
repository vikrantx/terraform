variable "resource_group_name" {
  default     = "rg-tf"
  description = "resource group name prefix"
}

variable "resource_group_name_prefix" {
  default     = "test-rg"
  description = "resource group name prefix"
}

variable "resource_group_location" {
  default     = "eastus"
  description = "Location of resource group"
}

variable "vnet_name" {
  default     = "vnet-tf"
  description = "Virtual Network name for weight tracker with load balancer and db vm project"
}

variable "resource_postfix" {
  default     = "tf-wt-app"
  description = "postfix for all resources created"
}

# variable "myVM_ip" {
#   type = string
#   description = "myVM-ip"
# }

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "resource_vm_count" {
  default     = 3
  description = "number of resources to be created"
}