


resource "azurerm_lb" "tf-vmss" {
  name                = "vmss-lb"
  location            = azurerm_resource_group.tf.location
  resource_group_name = azurerm_resource_group.tf.name

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

resource "azurerm_virtual_machine_scale_set" "tf-vmss" {
  name                = "tf-vmss"
  location            = azurerm_resource_group.tf.location
  resource_group_name = azurerm_resource_group.tf.name

  # automatic rolling upgrade
  automatic_os_upgrade = true
  upgrade_policy_mode  = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  # required when using rolling upgrade policy
  health_probe_id = azurerm_lb_probe.tf-lb-probe-vmss.id

  sku {
    name     = "Standard_B1s"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "tf-vmss-vm"
    admin_username       = "azureuser"
    admin_password = random_password.password.result
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.tf-pulic-subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss-bpepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.vmss-lbnatpool.id]
    }
  }
}