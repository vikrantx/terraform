resource "azurerm_virtual_network" "tf" {
  name                = var.vnet_name
  location            = var.resource_group_location
  address_space       = ["10.0.0.0/24"]
  resource_group_name = azurerm_resource_group.tf.name
}

#create private subnet
resource "azurerm_subnet" "tf-private-subnet" {
  name                 = "private-subnet"
  address_prefixes     = ["10.0.0.0/27"]
  resource_group_name  = azurerm_resource_group.tf.name
  virtual_network_name = azurerm_virtual_network.tf.name
}

#create public subnet
resource "azurerm_subnet" "tf-pulic-subnet" {
  name                 = "public-subnet"
  address_prefixes     = ["10.0.0.32/27"]
  resource_group_name  = azurerm_resource_group.tf.name
  virtual_network_name = azurerm_virtual_network.tf.name
}

#create postgres subnet
resource "azurerm_subnet" "tf-postgres-subnet" {
  name                 = "postgres-subnet"
  address_prefixes     = ["10.0.0.64/28"]
  resource_group_name  = azurerm_resource_group.tf.name
  virtual_network_name = azurerm_virtual_network.tf.name
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

#postgres flex private dns zone
resource "azurerm_private_dns_zone" "tf-postgres" {
  name                = "example.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.tf.name
}

#postgres flex server dns zone vnet link 
resource "azurerm_private_dns_zone_virtual_network_link" "tf-postgres" {
  name                  = "postgres-pvt-dns-zone-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.tf-postgres.name
  virtual_network_id    = azurerm_virtual_network.tf.id
  resource_group_name   = azurerm_resource_group.tf.name
}

#create public ip for load balancer
resource "azurerm_public_ip" "tf" {
  name                = "lb-public-ip"
  sku                 = "Standard"
  location            = azurerm_resource_group.tf.location
  resource_group_name = azurerm_resource_group.tf.name
  allocation_method   = "Static"
}

#create public network security group and rules
resource "azurerm_network_security_group" "tf-public-nsg" {
  name                = "public-nsg"
  location            = azurerm_resource_group.tf.location
  resource_group_name = azurerm_resource_group.tf.name

  security_rule {
    access                     = "Allow"
    description                = "AllowSSH"
    destination_address_prefix = "*"
    source_address_prefix      = "*"
    direction                  = "Inbound"
    name                       = "AllowSSHInBound"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
  }
  security_rule {
    access                     = "Allow"
    description                = "AllowWebapp"
    destination_address_prefix = "*"
    source_address_prefix      = "*"
    direction                  = "Inbound"
    name                       = "AllowWebAppInBound"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 8080
  }
  security_rule {
    access                     = "Deny"
    description                = "Deny all ports"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "DenyAll"
    priority                   = 510
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

#create private network security group and rules
resource "azurerm_network_security_group" "tf-private-nsg" {
  name                = "private-nsg"
  location            = azurerm_resource_group.tf.location
  resource_group_name = azurerm_resource_group.tf.name

  security_rule {
    access                     = "Allow"
    description                = "AllowSSH"
    destination_address_prefix = "*"
    source_address_prefix      = "10.0.0.32/27"
    direction                  = "Inbound"
    name                       = "AllowSSHInBound"
    priority                   = 110
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
  }

  security_rule {
    access                     = "Allow"
    description                = "AllowPostgres"
    destination_address_prefix = "*"
    source_address_prefix      = "10.0.0.32/27"
    direction                  = "Inbound"
    name                       = "AllowPostgresInBound"
    priority                   = 120
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 5432
  }


  security_rule {
    access                     = "Deny"
    description                = "Deny all ports"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "DenyAll"
    priority                   = 500
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

#create network interface
resource "azurerm_network_interface" "tf-nic" {
  count               = var.resource_vm_count
  name                = "app-vm-${count.index}-nic"
  location            = azurerm_resource_group.tf.location
  resource_group_name = azurerm_resource_group.tf.name

  ip_configuration {
    name                          = "app-vm-${count.index}-nic"
    subnet_id                     = azurerm_subnet.tf-pulic-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#create network interface for postgres vm
resource "azurerm_network_interface" "tf-nic-postgres" {
  name                = "app-vm-postgres-nic"
  location            = azurerm_resource_group.tf.location
  resource_group_name = azurerm_resource_group.tf.name

  ip_configuration {
    name                          = "app-vm-postgres-nic"
    subnet_id                     = azurerm_subnet.tf-private-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


#connect security group to public subnet
resource "azurerm_subnet_network_security_group_association" "tf-public-nsg-association" {
  subnet_id                 = azurerm_subnet.tf-pulic-subnet.id
  network_security_group_id = azurerm_network_security_group.tf-public-nsg.id
}

#connect security group to priate subnet
resource "azurerm_subnet_network_security_group_association" "tf-private-nsg-association" {
  subnet_id                 = azurerm_subnet.tf-private-subnet.id
  network_security_group_id = azurerm_network_security_group.tf-private-nsg.id
}


#check network interface for public subnet
