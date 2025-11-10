

data "azurerm_subnet" "subnet_data" { 
  for_each = var.bastion_details 
  name                 = each.value.bastion_subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}



resource "azurerm_public_ip" "bastionpip" {  
   for_each = var.bastion_details
  name                = each.value.bastionip_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastionhost" {
    for_each = var.bastion_details
  name                = each.value.bastion_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.subnet_data[each.key].id
    public_ip_address_id = azurerm_public_ip.bastionpip[each.key].id
  }
}