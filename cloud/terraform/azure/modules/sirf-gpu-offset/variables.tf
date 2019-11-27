variable "prebuilt_image_name" {
    description = "Name of packer image"
    type = string
}

variable "prebuilt_image_resource_group_name" {
    description = "Name of resource group containing gallery"
    type = string
}

variable "prebuilt_image_gallery_name" {
    description = "Name of shared image gallery containing packer image"
    type = string
}

variable "vm_location" {
    description = "The location to run"
    type = string
}

variable "prefix" {
    description = "Prefix to use for infrastructure"
    type = string
}

variable "vm_total_no_machines" {
    description = "Number of machines to build"  
    type = number
}

variable "vm_id_offset" {
    description = "Offset machine index"  
    type = number
}

variable "vm_jupyter_port" {
    description = "Port for jupyter service"  
    type = number
}

variable "vm_size" {
    description = "Size of machine to use"
    type = string
}

variable "vm_username" {
    description = "User account"
    type = string
}

variable "vm_password" {
    description = "User account password"
    type = string
}