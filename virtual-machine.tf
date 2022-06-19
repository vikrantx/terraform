#create virtual machine
resource "azurerm_linux_virtual_machine" "tf" {
  count               = var.resource_vm_count
  name                = "vm-${count.index}-${var.resource_postfix}"
  location            = azurerm_resource_group.tf.location
  resource_group_name = azurerm_resource_group.tf.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = random_password.password.result
  availability_set_id = azurerm_availability_set.avset-tf-wt.id

  network_interface_ids           = [element(azurerm_network_interface.tf-nic.*.id, count.index)]
  disable_password_authentication = false

  os_disk {
    name                 = "app-vm-disk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}



#create virtual machine for postgres DB
resource "azurerm_virtual_machine" "tf-postgres" {
  name                  = "vm-postgres"
  location              = azurerm_resource_group.tf.location
  resource_group_name   = azurerm_resource_group.tf.name
  network_interface_ids = [azurerm_network_interface.tf-nic-postgres.id]
  vm_size               = "Standard_B1s"

  os_profile {
    computer_name  = "app-vm-postgres"
    admin_username = "azureuser"
    admin_password = random_password.password.result
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  storage_os_disk {
    name              = "app-vm-disk-postgres"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "30"
  }
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}