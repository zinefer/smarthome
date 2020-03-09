# VARIABLES

variable "proxmox_host" {
  type    = string
}

variable "proxmox_user" {
  type    = string
  default = "root@pam"
}

variable "proxmox_password" {
  type    = string
}

variable "admin_password" {
  type    = string
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

## Provision PiHole

resource "random_password" "pihole" {
  length = 16
  special = true
  override_special = "_%@$"
}

resource "proxmox_lxc" "pihole" {
    target_node = "proxmox"
    ostemplate = "local:vztmpl/ubuntu-19.10-standard_19.10-1_amd64.tar.gz"
    storage = "local-lvm"
    unprivileged = true
    vmid = 333
    hostname = "pihole.test"
    password = random_password.pihole.result
}