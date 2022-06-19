resource "azurerm_lb" "tf" {
  name                = "lb-${var.resource_postfix}"
  location            = azurerm_resource_group.tf.location
  resource_group_name = azurerm_resource_group.tf.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "public-ip-config-${var.resource_postfix}"
    public_ip_address_id = azurerm_public_ip.tf.id
  }
}

resource "azurerm_lb_backend_address_pool" "tf" {
  name            = "lb-bepool-${var.resource_postfix}"
  loadbalancer_id = azurerm_lb.tf.id
}

resource "azurerm_lb_probe" "tf-lb-health-probe" {
  name            = "lb-health-probe-${var.resource_postfix}"
  loadbalancer_id = azurerm_lb.tf.id
  port            = 8080
}

resource "azurerm_lb_rule" "tf" {
  loadbalancer_id                = azurerm_lb.tf.id
  name                           = "lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "public-ip-config-${var.resource_postfix}"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.tf.id]
  probe_id                       = azurerm_lb_probe.tf-lb-health-probe.id
}

# resource "azurerm_network_interface_backend_address_pool_association" "tf" {
#     count = 3
#     network_interface_id = "${element(azurerm_network_interface.tf-nic.*.id, count.index)}"
#     ip_configuration_name = "app-vm-${count.index}-nic"
#     backend_address_pool_id = azurerm_lb_backend_address_pool.tf.id

# }

#load balancer NAT rule
resource "azurerm_lb_nat_rule" "tf-lb-nat-rule" {
  count                          = var.resource_vm_count
  resource_group_name            = azurerm_resource_group.tf.name
  loadbalancer_id                = azurerm_lb.tf.id
  name                           = "lb-nat-ssh-${count.index}"
  protocol                       = "Tcp"
  frontend_port                  = "20${count.index}"
  backend_port                   = 22
  frontend_ip_configuration_name = "public-ip-config-${var.resource_postfix}"
}

#nat rule asssociation
resource "azurerm_network_interface_nat_rule_association" "tf-lb-nat-association" {
  count                 = var.resource_vm_count
  network_interface_id  = azurerm_network_interface.tf-nic[count.index].id
  ip_configuration_name = "app-vm-${count.index}-nic"
  nat_rule_id           = azurerm_lb_nat_rule.tf-lb-nat-rule[count.index].id
}

#enable this
resource "azurerm_lb_backend_address_pool_address" "tf-lb-bepool-addr" {
  count                   = var.resource_vm_count
  name                    = "lb-bepool-address-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.tf.id
  virtual_network_id      = azurerm_virtual_network.tf.id
  ip_address              = azurerm_network_interface.tf-nic[count.index].private_ip_address

}