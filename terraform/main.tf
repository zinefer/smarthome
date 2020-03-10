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

# Providers

provider "proxmox" {
    pm_tls_insecure = true
    pm_api_url  = "https://${var.proxmox_host}:8006/api2/json"
    pm_user     = var.proxmox_user
    pm_password = var.proxmox_password
    pm_otp      = ""
}

# Provision Smarthome

module "pihole_container" {
  source = "./modules/container"

  providers = {
    proxmox = proxmox
  }

  ip    = "192.168.1.5"
  name  = "piholetest"
}

output "pihole_password" {
  value = module.pihole_container.password
}