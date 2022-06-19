# resource "azurerm_virtual_machine" "tf-postgres"{
#   name                  = var.vm_name
#   location              = var.rg_location
#   resource_group_name   = var.rg_name
#   network_interface_ids = var.nic_ids
#   vm_size               = var.vm_size

#   os_profile {
#     computer_name  = var.os_profile.computer_name
#     admin_username = var.os_profile.admin_username
#     admin_password = var.os_profile.admin_password
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
#   storage_os_disk {
#     name                 = var.storage_os_disk.name
#     caching              = "ReadWrite"
#     create_option        = "FromImage"
#     managed_disk_type    = var.storage_os_disk.managed_disk_type
#     disk_size_gb         = var.storage_os_disk.disk_size_gb
#   }
#   delete_os_disk_on_termination = true

#   storage_image_reference {
#     publisher = var.storage_image_reference.published
#     offer     = var.storage_image_reference.offer
#     sku       = var.storage_image_reference.sku
#     version   = var.storage_image_reference.version
#   }

# }