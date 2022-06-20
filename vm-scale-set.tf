


resource "azurerm_lb" "tf-vmss" {
  name                = "vmss-lb"
  location            = azurerm_resource_group.tf.location
  resource_group_name = azurerm_resource_group.tf.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "VmSSPublicIPAddress"
    public_ip_address_id = azurerm_public_ip.tf-vmss.id
  }
}

resource "azurerm_lb_backend_address_pool" "vmss-bpepool" {
  loadbalancer_id     = azurerm_lb.tf-vmss.id
  name                = "BackEndVmssAddressPool"
}

resource "azurerm_lb_nat_pool" "vmss-lbnatpool" {
  resource_group_name            = azurerm_resource_group.tf.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.tf-vmss.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "VmSSPublicIPAddress"
}

resource "azurerm_lb_probe" "tf-lb-probe-vmss" {
  loadbalancer_id     = azurerm_lb.tf-vmss.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = "/health"
  port                = 8080
}

resource "azurerm_linux_virtual_machine_scale_set" "tf-vmss" {
  name                = "tf-vmss"
  resource_group_name = azurerm_resource_group.tf.name
  location            = azurerm_resource_group.tf.location
  sku                 = "Standard_B1s"
  instances           = 3
  admin_username      = "azureuser"
  admin_password      = random_password.password.result
  disable_password_authentication = false


  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "vmss-ip-config"
      primary   = true
      subnet_id = azurerm_subnet.tf-pulic-subnet.id
    }
  }
}