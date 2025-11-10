
resource "azurerm_public_ip" "pipj" {
  name                = "PublicIPForLB"
  location            = "Australia East"
  resource_group_name = "Amitresource1"
  allocation_method   = "Static"
}
resource "azurerm_lb" "lb" {
  name                = "Loadbalancekar"
  location            = "Australia East"
  resource_group_name = "Amitresource1"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pipj.id
  }
}
resource "azurerm_lb_backend_address_pool" "backen1" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "frontEndAddressPool"
}
data "azurerm_network_interface" "vm1nic" {
  name                = "vm1-nic"
  resource_group_name = "Amitresource1"
}
data "azurerm_network_interface" "vm2nic" {
  name                = "vm2-nic"
  resource_group_name = "Amitresource1"
}
resource "azurerm_network_interface_backend_address_pool_association" "vm1" {
  network_interface_id    = data.azurerm_network_interface.vm1nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backen1.id
}
resource "azurerm_network_interface_backend_address_pool_association" "vm2" {
  network_interface_id    = data.azurerm_network_interface.vm2nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backen1.id
}
resource "azurerm_lb_probe" "health" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "ssh-running-probe"
  port            = 80
}
resource "azurerm_lb_rule" "example" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids =[azurerm_lb_backend_address_pool.backen1.id]
  probe_id = azurerm_lb_probe.health.id
}