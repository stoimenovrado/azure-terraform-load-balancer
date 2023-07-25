
provider "azurerm" {
  features {}
}

data "azurerm_ssh_public_key" "vm-login" {
  name                = var.ssh_key_name
  resource_group_name = var.ssh_rg_name
}

resource "azurerm_availability_set" "web_vm" {
  name                = var.web_availability_set_name
  resource_group_name = var.rg_name
  location            = var.location
}

resource "azurerm_linux_virtual_machine" "web_vm" {
  count               = var.web_vm_count
  name                = "${var.web_vm_name}-${count.index + 1}"
  resource_group_name = var.rg_name
  location            = var.location
  size                = var.web_vm_size
  admin_username      = var.admin_username

  disable_password_authentication = true

  network_interface_ids = [
    var.nic-web[count.index],
  ]
    
  admin_ssh_key {
    username   = var.admin_username
    public_key = data.azurerm_ssh_public_key.vm-login.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.web_vm_publisher
    offer     = var.web_vm_offer
    sku       = var.web_vm_sku
    version   = var.web_vm_version
  }

  availability_set_id = azurerm_availability_set.web_vm.id

}

resource "azurerm_virtual_machine_extension" "web_vm_extension" {
  count                = var.web_vm_count
  name                 = "${var.web_vm_extension_name}-${count.index + 1}"
  virtual_machine_id   = azurerm_linux_virtual_machine.web_vm[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
        "fileUris": ["${var.web_provision_file_uri}"],
        "commandToExecute": "${var.web_provision_command_exec}"
    }
SETTINGS
}
