resource "azurerm_postgresql_flexible_server" "tf-pg-flex-server" {
  name                   = "pg-server-${var.resource_postfix}"
  resource_group_name    = azurerm_resource_group.tf.name
  location               = azurerm_resource_group.tf.location
  version                = "12"
  delegated_subnet_id    = azurerm_subnet.tf-postgres-subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.tf-postgres.id
  administrator_login    = var.db_username
  administrator_password = var.db_password
  zone                   = "1"

  storage_mb = 32768

  sku_name   = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.tf-postgres]

}


#add network interface for postgres
