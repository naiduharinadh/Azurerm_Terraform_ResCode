# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}




# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}


subscription_id = "3e174af4-b1d5-41d7-8775-e351fc0fec65"
  client_id       = "9e61e14b-a4c1-4e6a-9e0e-8c95a4e408dd"
  client_secret   = "fX68Q~-hzRwRpQ0lRnc65woyvC2NBoRGboTzFaWY"
  tenant_id       = "8292aee4-c449-4f25-b860-7d4e0bbe134b"

}




# Create a resource group
resource "azurerm_resource_group" "TFExampGR1" {
  name     = "TFresource1"
  location = "West Europe"
}






# Create a virtual network within the resource group
resource "azurerm_virtual_network" "TFnetwork1" {
  name                = "TFnet1"
  resource_group_name = azurerm_resource_group.TFExampGR1.name
  location            = azurerm_resource_group.TFExampGR1.location
  address_space       = ["10.9.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "TFSubnet1" {
  name                 = "TFSubnet1"
  resource_group_name  = azurerm_resource_group.TFExampGR1.name
  virtual_network_name = azurerm_virtual_network.TFnetwork1.name
  address_prefixes     = ["10.9.1.0/24"]
}

# Create a network interface
resource "azurerm_network_interface" "TFNetInterface1" {
  name                = "TFNetInterface1"
  location            = azurerm_resource_group.TFExampGR1.location
  resource_group_name = azurerm_resource_group.TFExampGR1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.TFSubnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}





# Create a virtual machine
resource "azurerm_linux_virtual_machine" "TFVM1" {
  name                = "TFVM1"
  resource_group_name = azurerm_resource_group.TFExampGR1.name
  location            = azurerm_resource_group.TFExampGR1.location
  size                = "Standard_DS1_v2"
  
  disable_password_authentication =  false

  admin_username = "adminuser"
  admin_password = "P@ssw0rd1234"  # Replace with your desired password or use SSH keys

  network_interface_ids = [azurerm_network_interface.TFNetInterface1.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
