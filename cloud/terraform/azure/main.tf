terraform {
  
  # Configure use of terraform cloud backend
  backend "remote" {
    organization = "ccppetmr"

    workspaces {
      name = "synergistic-practical"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  version = "=1.36.0"
}

module "sirf_gpu_uksouth" {
  source = "./modules/sirf-gpu-offset"
  vm_location = "uksouth"
  vm_id_offset = 0
  prebuilt_image_name = var.shared_image_name
  prebuilt_image_resource_group_name = var.shared_image_rg_name
  prebuilt_image_gallery_name = var.shared_image_gallery_name
  prefix = "${var.vm_prefix}-gpu"
  vm_total_no_machines = 1
  vm_jupyter_port = 9999
  vm_size = "Standard_NC6_Promo"
  vm_username = var.vm_username
  vm_password = var.vm_password
}

# module "sirf_gpu_uksouth" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "uksouth"
#   vm_id_offset = 0
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 33
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NC6_Promo"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

module "sirf_gpu_uksouth2" {
  source = "./modules/sirf-gpu-offset"
  vm_location = "uksouth"
  vm_id_offset = 33
  prebuilt_image_name = var.shared_image_name
  prebuilt_image_resource_group_name = var.shared_image_rg_name
  prebuilt_image_gallery_name = var.shared_image_gallery_name
  prefix = "${var.vm_prefix}-gpu"
  vm_total_no_machines = 2
  vm_jupyter_port = 9999
  vm_size = "Standard_NC6"
  vm_username = var.vm_username
  vm_password = var.vm_password
}

# module "sirf_gpu_westeuropenv" {
#   source = "./modules/sirf-gpu-offset2"
#   vm_location = "westeurope"
#   vm_id_offset = 33
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 2
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NV6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_westeurope" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "westeurope"
#   vm_id_offset = 35
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 2
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NC6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_northeurope" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "northeurope"
#   vm_id_offset = 37
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 2
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NC6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_northeuropenv" {
#   source = "./modules/sirf-gpu-offset2"
#   vm_location = "northeurope"
#   vm_id_offset = 39
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 2
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NV6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_westus2" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "westus2"
#   vm_id_offset = 41
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 1
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NC6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_southcentralus" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "southcentralus"
#   vm_id_offset = 42
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 1
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NC6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_eastus" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "eastus"
#   vm_id_offset = 43
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 1
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NC6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_eastus2" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "eastus2"
#   vm_id_offset = 44
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 1
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NC6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_northcentralus" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "northcentralus"
#   vm_id_offset = 45
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 1
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NC6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_australiaeast" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "australiaeast"
#   vm_id_offset = 46
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 1
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NC6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_japaneast" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "japaneast"
#   vm_id_offset = 47
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 1
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NV6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_southeastasia" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "southeastasia"
#   vm_id_offset = 48
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 1
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NV6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }

# module "sirf_gpu_centralindia" {
#   source = "./modules/sirf-gpu-offset"
#   vm_location = "CentralIndia"
#   vm_id_offset = 49
#   prebuilt_image_name = var.shared_image_name
#   prebuilt_image_resource_group_name = var.shared_image_rg_name
#   prebuilt_image_gallery_name = var.shared_image_gallery_name
#   prefix = "${var.vm_prefix}-gpu"
#   vm_total_no_machines = 1
#   vm_jupyter_port = 9999
#   vm_size = "Standard_NV6"
#   vm_username = var.vm_username
#   vm_password = var.vm_password
# }


