resource "azurerm_resource_group" "rg" {
  name     = "semi-colon-vm"
  location = "UK South"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "myVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"  # Must be Static for Standard SKU
  sku                 = "Standard"  # Set SKU to Standard
}
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"   # Corrected here
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface" "nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myIPConfig"
    subnet_id                    = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"

    # Create a public IP
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS2_v2"

  # Specify the source image reference
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  # Define the operating system disk
  storage_os_disk {
    name              = "myVMosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"

    # Specify the source image
    managed_disk_type = "Standard_LRS"  # Specify disk type if needed
  }

  os_profile {
    computer_name  = "semi-colon"
    admin_username = "azureuser"
    admin_password = "bahnasy"  # Change this to a secure password
    
  }
 

  os_profile_linux_config {
    disable_password_authentication = true
     ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = file("/var/lib/jenkins/.ssh/id_rsa.pub")  
    }
  }
  
}
