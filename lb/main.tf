
provider "azurerm" {
  features {}
}

resource "azurerm_public_ip" "web_vm-lb" {
  name                = "pip-web_vm-lb"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_lb_backend_address_pool" "web_vm-backend-pool" {
  name                = "web_vm-backend-pool"
  loadbalancer_id     = azurerm_lb.web_vm-lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "web_vm-nic-backend-pool" {
  count                   = var.web_vm_count
  network_interface_id    = var.web-vm-nics[count.index]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_vm-backend-pool.id
}

resource "azurerm_lb" "web_vm-lb" {
  name                = "web_vm-lb"
  resource_group_name = var.rg_name
  location            = var.location

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.web_vm-lb.id
  }
}

resource "azurerm_lb_probe" "app-http" {
  loadbalancer_id     = azurerm_lb.web_vm-lb.id
  name                = "http-probe"
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 30
}

resource "azurerm_lb_rule" "web_vm-lb-rule" {
  name                            = "web_vm-lb-rule"
  loadbalancer_id                 = azurerm_lb.web_vm-lb.id
  protocol                        = "Tcp"
  frontend_port                   = 80
  backend_port                    = 80
  frontend_ip_configuration_name  = "PublicIPAddress"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.web_vm-backend-pool.id]
  probe_id                        = azurerm_lb_probe.app-http.id
}
