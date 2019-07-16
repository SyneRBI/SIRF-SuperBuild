provider "azurerm" {
  subscription_id 	= "${var.subscription_id}"
  client_id 		= "${var.client_id}"
  client_secret 	= "${var.client_secret}"
  tenant_id 		= "${var.tenant_id}"
}

variable "subscription_id" {
  description = "Enter Subscription ID for provisioning resources in Azure"
}

variable "client_id" {
  description = "Enter appId"
}

variable "client_secret" {
  description = "Enter Client secret (password)"
}

variable "tenant_id" {
  description = "Enter tenantId"
}

variable "vm_prefix" {
  description = "Enter VM prefix"
}

variable "vm_username" {
  description = "Enter admin username to SSH into Linux VM"
}

variable "vm_password" {
  description = "Enter admin password to SSH into VM"
}

variable "vm_jupyter_pwd" {
  description = "Enter password for Jupyter"
}

variable "vm_jupyter_port" {
  description = "Enter port number for Jupyter"
}

variable "location" {
  description = "The default Azure region for the resource provisioning"
}

variable "vm_size" {
  description = "The default VM size"
}

variable "vm_total_no_machines" {
  description = "Total number of VMs to create"
}