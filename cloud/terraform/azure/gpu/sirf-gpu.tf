terraform {
    required_version = ">= 0.12.4"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "mytfgroup" {
    name     = "${var.vm_prefix}-Group"
    location = "${var.location}"

    tags = {
        environment = "${var.vm_prefix} env"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "mytfnetwork" {
    name                = "${var.vm_prefix}-Vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.mytfgroup.name}"

    tags = {
        environment = "${var.vm_prefix} env"
    }
}

# Create subnet
resource "azurerm_subnet" "mytfsubnet" {
    name                 = "${var.vm_prefix}-Subnet"
    resource_group_name  = "${azurerm_resource_group.mytfgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.mytfnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "mytfpublicip" {
    count                        = "${var.vm_total_no_machines}"
    name                         = "${var.vm_prefix}-${count.index}-PublicIP"
    domain_name_label            = "${var.vm_prefix}-${count.index}"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.mytfgroup.name}"
    allocation_method            = "Dynamic"

    tags = {
        environment = "${var.vm_prefix} env"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "mytfsg" {
    name                = "${var.vm_prefix}-NetworkSecurityGroup"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.mytfgroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Jupyter"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "${var.vm_jupyter_port}"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "RDP"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "${var.vm_prefix} env"
    }
}

# Create network interface
resource "azurerm_network_interface" "mytfnic" {
    count                     = "${var.vm_total_no_machines}"
    name                      = "${var.vm_prefix}-${count.index}-NIC"
    location                  = "${var.location}"
    resource_group_name       = "${azurerm_resource_group.mytfgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.mytfsg.id}"

    ip_configuration {
        name                          = "${var.vm_prefix}-${count.index}-NicConfiguration"
        subnet_id                     = "${azurerm_subnet.mytfsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.mytfpublicip.*.id, count.index)}"
    }

    tags = {
        environment = "${var.vm_prefix} env"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        resource_group = "${azurerm_resource_group.mytfgroup.name}"
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mytfstorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.mytfgroup.name}"
    location                    = "${var.location}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "${var.vm_prefix} env"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "mytfvm" {
    count                 = "${var.vm_total_no_machines}"
    name                  = "${var.vm_prefix}-${count.index}"
    location              = "${var.location}"
    resource_group_name   = "${azurerm_resource_group.mytfgroup.name}"
    network_interface_ids = ["${element(azurerm_network_interface.mytfnic.*.id, count.index)}"]
    vm_size               = "${var.vm_size}"

    storage_os_disk {
        name              = "${var.vm_prefix}-${count.index}-OsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    
    delete_os_disk_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.vm_prefix}-${count.index}"
        admin_username = "${var.vm_username}"
        admin_password = "${var.vm_password}"
    }
    
    os_profile_linux_config {
        disable_password_authentication = false
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mytfstorageaccount.primary_blob_endpoint}"
    }

    connection {
        user     = "${var.vm_username}"
        password = "${var.vm_password}"
        host = "${var.vm_prefix}-${count.index}.${var.location}.cloudapp.azure.com"
        timeout = "10m"
    }
    provisioner "file" {
        source      = "../scripts/provision.sh"
        destination = "/home/${var.vm_username}/provision.sh"
    }

    provisioner "file" {
        source      = "../scripts/launch.sh"
        destination = "/home/${var.vm_username}/launch.sh"
    }

    provisioner "file" {
        source      = "../scripts/install_prerequisites.sh"
        destination = "/home/${var.vm_username}/install_prerequisites.sh"
    }

    provisioner "file" {
        source      = "../scripts/jupyter_set_pwd.sh"
        destination = "/home/${var.vm_username}/jupyter_set_pwd.sh"
    }

    provisioner "file" {
        source      = "../scripts/jupyter.service"
        destination = "/home/${var.vm_username}/jupyter.service"
    }

    provisioner "file" {
        source      = "install_gpu_prerequisites.sh"
        destination = "/home/${var.vm_username}/install_gpu_prerequisites.sh"
    }

    provisioner "file" {
        source      = "install_gpu_rdp.sh"
        destination = "/home/${var.vm_username}/install_rdp.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo bash ~/install_gpu_prerequisites.sh",
            "sudo bash ~/install_prerequisites.sh",
            "bash ~/provision.sh ${var.vm_jupyter_pwd} ${var.vm_jupyter_port}",
            "sudo systemctl enable jupyter.service",
            "sudo systemctl start jupyter.service",
            "sudo bash ~/install_rdp.sh",
            "sudo chown -R ${var.vm_username}:${var.vm_username} /home/${var.vm_username}",
            "rm ~/install_prerequisites.sh ~/provision.sh ~/jupyter_set_pwd.sh ~/install_rdp.sh ~/install_gpu_prerequisites.sh"
        ]
    }

    tags = {
        environment = "${var.vm_prefix} env"
    }

}
