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
  ip   = "192.168.47.3"
}

module "pihole_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }
  
  name = "pihole"
  ip   = "192.168.47.5"
  os   = "debian-9.0-standard_9.7-1_amd64.tar.gz"
}

module "files_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  name   = "files"
  ip     = "192.168.47.6"
  mounts = [ 
    {mp="/mnt/private",       volume="/mnt/pve/cold/private"},
    {mp="/mnt/code",          volume="/mnt/pve/hot/code"},
    {mp="/mnt/skunkworks",    volume="/mnt/pve/hot/skunkworks"}, 
    {mp="/mnt/config/hassio", volume="/mnt/pve/hot/config/hassio"},
    {mp="/mnt/torrents",      volume="/mnt/pve/cold/public/torrents"},
    {mp="/mnt/media",         volume="/mnt/pve/cold/public/media"},
  ]
}

module "home_vm" {
  source = "./modules/vm"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  name     = "home"
  ip       = "192.168.47.10"
  memory   = 4096
  cores    = 4
  disksize = 6
}

module "code_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  name     = "code"
  ip       = "192.168.47.20"
  disksize = 3
  mounts = [ 
    {mp="/mnt/code",          volume="/mnt/pve/hot/code"},
    {mp="/mnt/config/hassio", volume="/mnt/pve/hot/config/hassio"},
  ]
}

module "torrents_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  name     = "torrents"
  ip       = "192.168.47.30"
  cores    = 2
  disksize = 3
  mounts = [
    {mp="/mnt/torrents",        volume="/mnt/pve/cold/public/torrents"},
    {mp="/mnt/downloads",       volume="/mnt/pve/cold/public/downloads"},
    {mp="/mnt/media",           volume="/mnt/pve/cold/public/media"},
    {mp="/mnt/config/rtorrent", volume="/mnt/pve/hot/config/rtorrent"},
  ]
}

# Outputs

output "admin_password" {
  value     = var.admin_password
  sensitive = true
}