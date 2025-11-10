
data "azurerm_key_vault" "keyvault" {
  for_each = var.vmmachine_details
  name                = "Amitkeyvaultcredential"
  resource_group_name = "Amitresource1"
}
resource "random_password" "apass" {
  for_each = var.vmmachine_details
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "password" {
  for_each = var.vmmachine_details
  name         = "${each.value.vm_name}-password"
  value        = random_password.apass[each.key].result
  key_vault_id = data.azurerm_key_vault.keyvault[each.key].id
}
data "azurerm_subnet" "subnet_data" {
  for_each = var.vmmachine_details
  name                 = each.value.subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}
data "azurerm_network_security_group" "sskr" {
  name                = "VElectric_Security"
  resource_group_name = "Amitresource1"
}

resource "azurerm_network_interface" "nic" {
  for_each = var.vmmachine_details
  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet_data[each.key].id
    private_ip_address_allocation = "Dynamic"
    }  
}
locals {
  startup_script = <<-EOT
    #!/bin/bash
    apt update
    apt install -y nginx
    service start nginx
    service enable nginx
  EOT
}
resource "azurerm_network_interface_security_group_association" "example" {
  for_each = var.vmmachine_details
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = data.azurerm_network_security_group.sskr.id
}

resource "azurerm_linux_virtual_machine" "VM" {
  for_each = var.vmmachine_details
  name                = each.value.vm_name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  size                = each.value.size
  admin_username      = "irisha"
  admin_password      = azurerm_key_vault_secret.password[each.key].value
  disable_password_authentication = false
  network_interface_ids = [ azurerm_network_interface.nic[each.key].id ]

 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
    
  }
    custom_data = base64encode(local.startup_script)
}