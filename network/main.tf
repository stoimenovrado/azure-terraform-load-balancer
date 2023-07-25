
provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.rg_name
  location            = var.location
  address_space       = ["${var.vnet_address_space}"]
}

#Web network settings below

resource "azurerm_subnet" "web_vm" {
  name                 = "web_vm"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.web_subnet}"]
}

resource "azurerm_network_interface" "web_vm" {
  count               = var.web_vm_count
  name                = "web_vm-nic-${count.index + 1}"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "web_vm" {
  count                     = var.web_vm_count
  network_interface_id      = azurerm_network_interface.web_vm[count.index].id
  network_security_group_id = azurerm_network_security_group.web_vm.id
}

resource "azurerm_network_security_group" "web_vm" {
  name                = "web_vm-sg"
  resource_group_name = var.rg_name
  location            = var.location

  security_rule {
    name                       = "web_vm-80"
    priority                   = 340
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "web_vm-443"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "web_vm-22"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "web_vm-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#DB Network settings below

resource "azurerm_subnet" "db_vm" {
  name                 = "db_vm"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.db_subnet}"]
}

resource "azurerm_network_interface" "db_vm" {
  name                = "db_vm-nic"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.db_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "db_vm" {
  network_interface_id      = azurerm_network_interface.db_vm.id
  network_security_group_id = azurerm_network_security_group.db_vm.id
}

resource "azurerm_network_security_group" "db_vm" {
  name                = "db_vm-sg"
  resource_group_name = var.rg_name
  location            = var.location

  security_rule {
    name                       = "db_vm-3306"
    priority                   = 340
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "10.69.69.0/26" #For the web machines subnet -or- "VirtualNetwork" for access from all machines in the subnet
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "db_vm-22"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "db_vm-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Private DNS zone

resource "azurerm_private_dns_zone" "pr_dns" {
  name                        = var.private_dns_zone_name
  resource_group_name         = var.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pr_dns" {
  name                  = "network-link"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.pr_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_a_record" "db_vm" {
  name                  = "db"
  zone_name             = azurerm_private_dns_zone.pr_dns.name
  resource_group_name   = var.rg_name
  ttl                   = 300
  records               = [var.db-prip]
}

resource "azurerm_private_dns_a_record" "web_vm" {
  count                 = var.web_vm_count
  name                  = "web-${count.index + 1}"
  zone_name             = azurerm_private_dns_zone.pr_dns.name
  resource_group_name   = var.rg_name
  ttl                   = 300
  records               = [var.web-prip[count.index]]
}

# Jump Host Network

resource "azurerm_subnet" "jump_host" {
  name                 = "jump_host"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.jh_subnet}"]
}

resource "azurerm_public_ip" "jump-host" {
  name                = "pip-jump-host"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "jump_host" {
  name                = "jump_host-nic"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jump_host.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jump-host.id
  }
}

resource "azurerm_network_interface_security_group_association" "jump_host" {
  network_interface_id      = azurerm_network_interface.jump_host.id
  network_security_group_id = azurerm_network_security_group.jump_host.id
}

resource "azurerm_network_security_group" "jump_host" {
  name                = "jump_host-sg"
  resource_group_name = var.rg_name
  location            = var.location

    security_rule {
    name                       = "jump_host-22"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "jump_host-out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}