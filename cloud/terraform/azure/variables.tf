variable "vm_prefix" {
    description = "Prefix"
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

variable "shared_image_gallery_name" {
    description = "Shared image gallery name"
    type = string
}

variable "shared_image_rg_name" {
    description = "Gallery resource group name"
    type = string
}

variable "shared_image_name" {
    description = "Shared image name"
    type = string
}