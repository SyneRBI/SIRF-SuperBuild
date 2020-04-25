
Demonstrates how to build and install [SIRF](https://github.com/SyneRBI/SIRF) on an [Azure](https://azure.microsoft.com) VM using [Packer](https://www.packer.io/) and [Terraform](https://www.terraform.io/). The VM is described in Packer files. Packer is used to build an image of the VM. Terraform deploys VMs, and their associated infrastructure in the cloud and then performs further configuration. There is currently GPU support (NVIDIA).

An Azure account is required for deployment. [Terraform Cloud](https://app.terraform.io) is used to store the [infrastructure state remotely](https://www.terraform.io/docs/state/remote.html). This is optional, but recommended.

*This configuration will currently deploy the `symposium2019` branch of the [SyneRBI VM](https://github.com/SyneRBI/SyneRBI_VM).*

# Prerequisites

## [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## [Install Packer](https://www.packer.io/downloads.html)

## [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)

## Configure access to Azure
The following instructions make use of the *Azure CLI*. All of these steps can be carried out in the Azure web portal, but this is not covered here.

- Login to your account:
```bash
az login
```
- Query your Azure account to get a list of subscription and tenant ID values:
```bash
az account show --query "{subscriptionId:id, tenantId:tenantId}"
```
- Note the `subscriptionId` and `tenantId` for future use.
- Set the environment variable `SUBSCRIPTION_ID` to the subscription ID returned by the `az account show` command. In Bash, this would be:
```bash
export SUBSCRIPTION_ID=your_subscription_id
```
- Create an Azure service principal to use:
```bash
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"
```
- Make a note of the `appId` and `password`

## Configure Azure environment variables
```bash
export ARM_SUBSCRIPTION_ID=${SUBSCRIPTION_ID}
export ARM_TENANT_ID=<APP_ID>
export ARM_CLIENT_ID=<CLIENT_ID>
export ARM_CLIENT_SECRET=<password>
export ARM_ENVIRONMENT=public
export TF_VAR_shared_image_name=sirfImageDef
export TF_VAR_shared_image_rg_name=galleryRG
export TF_VAR_shared_image_gallery_name=imgGallery
export TF_VAR_vm_prefix=sirf
export TF_VAR_vm_username=sirfuser
export TF_VAR_vm_password="virtual%1"
```

## Build image on Azure with Packer
- Copy `creds.json.skeleton` to `creds.json`:
```bash
cp creds.json.skeleton creds.json
```
- Create a resource group:
```bash
az group create -n sirf-rg -l uksouth
```
- Create a storage group on Azure:
```bash
az storage account create -n sirfsa -g sirf-rg -l uksouth --sku Standard_LRS
```
These are the defaults for the resource group and storage account. If changes are made, they should also be reflected in `creds.json`.

- Change into the packer directory: `cd packer`
- Build the image:
```bash
packer build -var-file=../creds.json sirf-gpu.json
```

This will take some time (~30-40 minutes). If the image already exists and it is necessary to overwrite it, the `-force` flag must be used.

## Create shared image gallery 

If there is a desire/need to deploy across multiple geographical data centres, then a [shared image gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/shared-image-galleries) can be used to deploy image replicates globally. As the image is currently ~100 GB, it can take a significant amount of time to replicate to distant data centres e.g. UK to Australia, so this should be factored in to the set up time.

- Create a resource group for the image gallery:
```bash
az group create --name galleryRG --location uksouth
```
- Create an image gallery:
```bash
az sig create --resource-group galleryRG --gallery-name imgGallery
```
- Create an image definition:
```bash
az sig image-definition create \
--resource-group galleryRG \
--gallery-name imgGallery \
--gallery-image-definition sirfImageDef \
--publisher INM \
--offer SIRF \
--sku 18.04-LTS \
--os-type Linux
```
- Create an image version:
```bash
az sig image-version create \
--resource-group galleryRG \
--gallery-name imgGallery \
--gallery-image-definition sirfImageDef \ --gallery-image-version 0.0.1 \ 
--target-regions uksouth=2 eastus2 westeurope \
--managed-image "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/sirf-rg/providers/Microsoft.Compute/images/sirf-gpu-UbuntuServer-18.04-LTS"
```
This will clone two replicates into `uksouth`, and one into `eastus2` and `westeurope`. As a rule of thumb, it is good practice to have one replicate per region per 20 VMs that will be deployed.

## Configure Terraform remote backend
- Change back to the `azure` directory.
- Execute `configure_azure.sh`. This will create a resource group and the credentials to use [Azure as the remote backend](https://www.terraform.io/docs/backends/types/azurerm.html) storage for [Terraform state files](https://www.terraform.io/docs/state/remote.html).
- Set access key as environment variable:
```bash
export ARM_ACCESS_KEY=<access_key>
```
- Edit the `main.tf` and replace the value of `storage_account_name` with the output of `configure_azure.sh` previously:
```
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateXXXXX"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
```

## Configure Terraform environment variables
```bash
export TF_VAR_shared_image_name=sirfImageDef
export TF_VAR_shared_image_rg_name=galleryRG
export TF_VAR_shared_image_gallery_name=imgGallery
export TF_VAR_vm_prefix=sirf
export TF_VAR_vm_username=sirfuser
export TF_VAR_vm_password="virtual%1"
```

## Running the Terraform script
- Initialise Terraform:
```shell
terraform init
```
- To preview the actions that Terraform will take, run:
```shell
terraform plan 
```
- To run the script:
```shell 
terraform apply 
```
- If this succeeded, a single VM called `sirf-gpu-0` will be running on Azure. To create more VMs, modify `vm_total_no_machines` in the the module(s) in `main.tf`. Then `terraform plan` and `terraform apply` again. This will add more machines, while leaving the existing ones intact.

- To access the machine via ssh:
```shell
ssh USERNAME@PUBLICIP
```
where `USERNAME` is the value set for `vm_username` (default: `sirfuser`) and `PUBLICIP` is the public IP address. The password for access to the virtual machine is the value of `vm_password` (default: `virtual%1`).

## Jupyter
Once built, a Jupyter notebook will be running. The URL can be accessed from a web browser:
```
https://<PUBLICIP>:<JUPPORT>
```
where `PUBLICIP` is the IP address found previously and `JUPPORT` is the Jupyter server port set by `vm_jupyter_port` (default: `9999`). The password for access to the notebook is controlled by the variable `vm_jupyter_pwd` (default: `virtual%1`).

## Remote desktop
A remote desktop to the VM is available. See the [instructions](https://github.com/UCL/terraform-azure-sirf/wiki/Remote-desktop) on the wiki.

## Removing the infrastructure
```shell
terraform destroy 
```
To avoid incurring unexpected costs, it is highly recommended that you check the Azure web portal to ensure that all resources have successfully been destroyed.

## Troubleshooting
If you get an error related to `SkuNotAvailable`, try to display all available machine types and see if the chosen machine exists in the region:
```
az vm list-skus --output table
```
