resource "azurerm_availability_set" "avset-tf-wt" {
  name                         = "avset-${var.resource_postfix}"
  location                     = azurerm_resource_group.tf.location
  resource_group_name          = azurerm_resource_group.tf.name
  platform_fault_domain_count  = var.resource_vm_count
  platform_update_domain_count = var.resource_vm_count
  managed                      = true
}