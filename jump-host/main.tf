
provider "azurerm" {
  features {}
}

data "azurerm_ssh_public_key" "jump-host-login" {
  name                = var.ssh_key_jh_name
  resource_group_name = var.ssh_rg_name
}

resource "azurerm_linux_virtual_machine" "jump-host-vm" {
  name                = var.jh_vm_name
  resource_group_name = var.rg_name
  location            = var.location
  size                = var.jh_vm_size
  admin_username      = var.admin_username
  disable_password_authentication = true
  network_interface_ids = [
    var.nic-jh,
  ]
    
  admin_ssh_key {
    username   = var.admin_username
    public_key = data.azurerm_ssh_public_key.jump-host-login.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.jh_vm_publisher
    offer     = var.jh_vm_offer
    sku       = var.jh_vm_sku
    version   = var.jh_vm_version
  }
      provisioner "file" {
    source      = "./jump-host/key/${var.key_file_name}"
    destination = "/tmp/${var.key_file_name}"

    connection {
      type        = "ssh"
      host        = self.public_ip_address
      user        = var.admin_username
      private_key = file(var.key_file_location)
    }
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir /home/radoslv/ssh-keys",
      "mv /tmp/${var.key_file_name} /home/radoslv/ssh-keys/",
      "sudo chmod 400 /home/radoslv/ssh-keys/${var.key_file_name}",
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip_address
      user        = var.admin_username
      private_key = file(var.key_file_location)
    }
  }
}
