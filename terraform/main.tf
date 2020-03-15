# VARIABLES

variable "proxmox_host" {
  type = string
}

variable "proxmox_user" {
  type    = string
  default = "root@pam"
}

variable "proxmox_password" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "proxmox_pub_keys" {
  type = string
}

# Providers

provider "proxmox" {
    pm_tls_insecure = true
    pm_api_url  = "https://${var.proxmox_host}:8006/api2/json"
    pm_user     = var.proxmox_user
    pm_password = var.proxmox_password
    pm_otp      = ""
}

# Provision Smarthome

module "vpn_vm" {
  source = "./modules/vm"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  name = "vpn"
  ip   = "192.168.1.3"
}

module "pihole_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }
  
  name = "piholetest"
  ip   = "192.168.1.5"
  os    = "debian-9.0-standard_9.7-1_amd64.tar.gz"
}

module "dev_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  name = "dev"
  ip   = "192.168.1.20"
}

# Outputs

output "admin_password" {
  value     = var.admin_password
  sensitive = true
}