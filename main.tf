terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.64.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  json_vars = jsondecode(file("${path.module}/variables.json"))
}

resource "azurerm_resource_group" "rg_name" {
  name     = local.json_vars.general.rg_name
  location = local.json_vars.general.location
}

module "network" {
  source                = "./network"
  rg_name               = azurerm_resource_group.rg_name.name
  location              = azurerm_resource_group.rg_name.location
  web-prip              = module.web.private_ip_address
  db-prip               = module.db.private_ip_address
  vnet_name             = local.json_vars.network.vnet_name
  vnet_address_space    = local.json_vars.network.vnet_address_space
  web_subnet            = local.json_vars.network.web_subnet
  db_subnet             = local.json_vars.network.db_subnet
  jh_subnet             = local.json_vars.network.jh_subnet
  private_dns_zone_name = local.json_vars.network.private_dns_zone_name
}

module "web" {
  source                    = "./web"
  rg_name                    = azurerm_resource_group.rg_name.name
  location                   = azurerm_resource_group.rg_name.location
  ssh_rg_name                = local.json_vars.general.ssh_rg_name
  ssh_key_name               = local.json_vars.general.ssh_key_name
  admin_username             = local.json_vars.general.admin_username
  web_vm_size                = local.json_vars.web_vms.web_vm_size
  web_vm_name                = local.json_vars.web_vms.web_vm_name
  web_vm_count               = local.json_vars.web_vms.web_vm_count
  web_availability_set_name  = local.json_vars.web_vms.web_availability_set_name
  web_vm_extension_name      = local.json_vars.web_vms.web_vm_extension_name
  web_vm_publisher           = local.json_vars.web_vms.web_vm_publisher
  web_vm_offer               = local.json_vars.web_vms.web_vm_offer
  web_vm_sku                 = local.json_vars.web_vms.web_vm_sku
  web_vm_version             = local.json_vars.web_vms.web_vm_version
  web_provision_file_uri     = local.json_vars.web_vms.web_provision_file_uri
  web_provision_command_exec = local.json_vars.web_vms.web_provision_command_exec  
  nic-web                    = module.network.azurerm_network_interface_web
}

module "db" {
  source                    = "./db"
  rg_name                   = azurerm_resource_group.rg_name.name
  location                  = azurerm_resource_group.rg_name.location
  ssh_rg_name               = local.json_vars.general.ssh_rg_name
  ssh_key_name              = local.json_vars.general.ssh_key_name
  admin_username            = local.json_vars.general.admin_username
  db_vm_size                = local.json_vars.db_vm.db_vm_size
  db_vm_name                = local.json_vars.db_vm.db_vm_name
  db_vm_extension_name      = local.json_vars.db_vm.db_vm_extension_name
  db_vm_publisher           = local.json_vars.db_vm.db_vm_publisher
  db_vm_offer               = local.json_vars.db_vm.db_vm_offer
  db_vm_sku                 = local.json_vars.db_vm.db_vm_sku
  db_vm_version             = local.json_vars.db_vm.db_vm_version
  db_provision_file_uri     = local.json_vars.db_vm.db_provision_file_uri
  db_provision_command_exec = local.json_vars.db_vm.db_provision_command_exec
  nic-db                    = module.network.azurerm_network_interface_db
}

module "lb" {
  source       = "./lb"
  rg_name      = azurerm_resource_group.rg_name.name
  location     = azurerm_resource_group.rg_name.location
  nic-web      = module.network.azurerm_network_interface_web
  vnet         = module.network.azurerm_virtual_network_id
  web-vm-nics  = module.web.web-vm-nic_ids
}

module "jump-host" {
  source            = "./jump-host"
  rg_name           = azurerm_resource_group.rg_name.name
  location          = azurerm_resource_group.rg_name.location
  ssh_rg_name       = local.json_vars.general.ssh_rg_name
  admin_username    = local.json_vars.general.admin_username
  ssh_key_jh_name   = local.json_vars.jh_vm.ssh_key_jh_name
  jh_vm_size        = local.json_vars.jh_vm.jh_vm_size
  jh_vm_name        = local.json_vars.jh_vm.jh_vm_name
  jh_vm_publisher   = local.json_vars.jh_vm.jh_vm_publisher
  jh_vm_offer       = local.json_vars.jh_vm.jh_vm_offer
  jh_vm_sku         = local.json_vars.jh_vm.jh_vm_sku
  jh_vm_version     = local.json_vars.jh_vm.jh_vm_version
  key_file_name     = local.json_vars.jh_vm.key_file_name
  key_file_location = local.json_vars.jh_vm.key_file_location
  nic-jh            = module.network.azurerm_network_interface_jh
}