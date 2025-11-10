## module code for resourcegroup##
module "mainresource" { 
    source = "../../modules/azure_resource_group"
    rg_details=var.vresource
  
}
## Module code for Storage
module "mainstorage" {
    depends_on = [ module.mainresource ]
    source = "../../modules/azurerm_storage_account"
    storage_account_details= var.vstoreplace
  
}
##Module code for Virtual Network
module "vnet" {
    depends_on = [ module.mainresource ]
    source = "../../modules/azurerm_virtual_network"
    vnets=var.vspace
  
}
## Module for Subnet
module "subnet" {
    depends_on = [ module.vnet ]
    source = "../../modules/azurerm_subnet"
    subnets=var.vsubnet
}
## Module for VIrtual Machine
module "virtual_machine" {
    depends_on = [module.vnet,module.subnet,module.keyvault,module.secur]
    source = "../../modules/azurerm_virtual_machine"
    vmmachine_details = var.vms
}

## Module for Bastion Host
module "bastion" {
    depends_on = [module.vnet,module.subnet,module.virtual_machine]
    source = "../../modules/azurerm_bastion-host"
    bastion_details = var.Bastion
}

##Module for Security
module "secur" {
    depends_on = [module.mainresource]
    source = "../../modules/azurerm_security_group"
    powersecurity =var.securityman
  
}

##Module for Keyvault
module "keyvault" {
    depends_on = [module.mainresource]
    source = "../../modules/azurerm_key_vault"
    key_vaults = var.key_vaults
}   

##Module for loadbalancer
module "Trafficbalancer" {
    depends_on = [ module.mainresource,module.vnet,module.virtual_machine ]
    source = "../../modules/azurermloadbalacer"
    lbpower = var.lbpower
}