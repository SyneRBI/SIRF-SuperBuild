# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "mytfgroup" {
    name     = "${var.prefix}-${var.vm_location}-Group"
    location = "${var.vm_location}"

    tags = {
        environment = "${var.prefix} env"
    }

    lifecycle {
        prevent_destroy = true
    }
}

# Create virtual network
resource "azurerm_virtual_network" "mytfnetwork" {
    name                = "${var.prefix}-Vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.vm_location}"
    resource_group_name = "${azurerm_resource_group.mytfgroup.name}"

    tags = {
        environment = "${var.prefix} env"
    }
}

# Create subnet
resource "azurerm_subnet" "mytfsubnet" {
    name                 = "${var.prefix}-Subnet"
    resource_group_name  = "${azurerm_resource_group.mytfgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.mytfnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "mytfpublicip" {
    count                        = "${var.vm_total_no_machines}"
    name                         = "${var.prefix}-${count.index + var.vm_id_offset}-PublicIP"
    domain_name_label            = "${var.prefix}-${count.index + var.vm_id_offset}"
    location                     = "${var.vm_location}"
    resource_group_name          = "${azurerm_resource_group.mytfgroup.name}"
    allocation_method            = "Dynamic"

    tags = {
        environment = "${var.prefix} env"
    }
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "mytfsg" {
    name                = "${var.prefix}-NetworkSecurityGroup"
    location            = "${var.vm_location}"
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

    security_rule {
        name                       = "Jupyter_8888"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8888"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "${var.prefix} env"
    }

    lifecycle {
        prevent_destroy = true
    }
}

# Create network interface
resource "azurerm_network_interface" "mytfnic" {
    count                     = "${var.vm_total_no_machines}"
    name                      = "${var.prefix}-${count.index + var.vm_id_offset}-NIC"
    location                  = "${var.vm_location}"
    resource_group_name       = "${azurerm_resource_group.mytfgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.mytfsg.id}"

    ip_configuration {
        name                          = "${var.prefix}-${count.index + var.vm_id_offset}-NicConfiguration"
        subnet_id                     = "${azurerm_subnet.mytfsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.mytfpublicip.*.id, count.index)}"
    }

    tags = {
        environment = "${var.prefix} env"
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
    location                    = "${var.vm_location}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "${var.prefix} env"
    }

    lifecycle {
        prevent_destroy = true
    }
}

data "azurerm_shared_image" "prebuilt" {
    name                = "${var.prebuilt_image_name}"
    resource_group_name = "${var.prebuilt_image_resource_group_name}"
    gallery_name        = "${var.prebuilt_image_gallery_name}"
}
# Create virtual machine
resource "azurerm_virtual_machine" "mytfvm" {
    count                 = "${var.vm_total_no_machines}"
    name                  = "${var.prefix}-${count.index + var.vm_id_offset}"
    location              = "${var.vm_location}"
    resource_group_name   = "${azurerm_resource_group.mytfgroup.name}"
    network_interface_ids = ["${element(azurerm_network_interface.mytfnic.*.id, count.index)}"]
    vm_size               = "${var.vm_size}"

    storage_os_disk {
        name              = "${var.prefix}-${count.index + var.vm_id_offset}-OsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    #storage_data_disk {
    #    name              = "${var.prefix}-${count.index}-DataDisk"
    #    managed_disk_type = "Standard_LRS"
    #    create_option     = "Empty"
    #    lun               = 0
    #    disk_size_gb      = "50"
    #}
    
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        id = "${data.azurerm_shared_image.prebuilt.id}"
    }

    os_profile {
        computer_name  = "${var.prefix}-${count.index + var.vm_id_offset}"
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
        host = "${var.prefix}-${count.index + var.vm_id_offset}.${var.vm_location}.cloudapp.azure.com"
        timeout = "10m"
    }

    provisioner "file" {
        source      = "./modules/sirf-gpu-offset/install_gpu_rdp.sh"
        destination = "/tmp/install_rdp.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo bash /tmp/install_rdp.sh",
            "sudo cp /tmp/install_rdp.sh /root/install_rdp.sh"
        ]
    }

    tags = {
        environment = "${var.prefix} env"
    }

}