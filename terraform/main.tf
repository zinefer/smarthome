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

variable "proxmox_pub_keys" {
  type = string
}

# Providers

terraform {
  required_providers {
    proxmox = {
      source = "ondrejsika/proxmox"
      version = "2020.9.21"
    }
  }
}

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

  os = "ubuntu-20.04-standard_20.04-1_amd64.tar.gz"

  name   = "files"
  ip     = "192.168.47.6"
  cores  = 2
  mounts = [ 
    {mp="/mnt/private",    volume="/mnt/pve/cold/private"},
    {mp="/mnt/users",      volume="/mnt/pve/cold/users"},
    {mp="/mnt/code",       volume="/mnt/pve/hot/code"},
    {mp="/mnt/skunkworks", volume="/mnt/pve/hot/skunkworks"}, 
    {mp="/mnt/config",     volume="/mnt/pve/hot/config"},
    {mp="/mnt/storage",    volume="/mnt/pve/cold/storage"},
    {mp="/mnt/downloads",  volume="/mnt/pve/cold/public/downloads"},
    {mp="/mnt/torrents",   volume="/mnt/pve/cold/public/torrents"},
    {mp="/mnt/media",      volume="/mnt/pve/cold/public/media"},
  ]
}

module "metrics_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  os = "ubuntu-20.04-standard_20.04-1_amd64.tar.gz"

  name     = "metrics"
  ip       = "192.168.47.7"
  memory   = 512
  disksize = 4
  mounts = [ 
    {mp="/mnt/storage/grafana",  volume="/mnt/pve/cold/storage/grafana"},
    {mp="/mnt/storage/influxdb", volume="/mnt/pve/cold/storage/influxdb"}
  ]
}

module "backups_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  name     = "backups"
  ip       = "192.168.47.8"
  memory   = 1024
  mounts = [ 
    {mp="/mnt/code",       volume="/mnt/pve/hot/code"},
    {mp="/mnt/config",     volume="/mnt/pve/hot/config"},   
    {mp="/mnt/skunkworks", volume="/mnt/pve/hot/skunkworks"},
    {mp="/mnt/users",      volume="/mnt/pve/cold/users"},
    {mp="/mnt/private",    volume="/mnt/pve/cold/private"}
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
  disksize = 10

  provisioner = "ssh -oStrictHostKeyChecking=no root@proxmox.pintail 'qm set 10010 -usb0 host=10c4:8a2a'"
}

module "code_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  name     = "code"
  ip       = "192.168.47.20"
  memory   = 1024
  disksize = 5
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
  memory   = 512
  cores    = 2
  disksize = 3
  mounts = [
    {mp="/mnt/torrents",        volume="/mnt/pve/cold/public/torrents"},
    {mp="/mnt/downloads",       volume="/mnt/pve/cold/public/downloads"},
    {mp="/mnt/media",           volume="/mnt/pve/cold/public/media"},
    {mp="/mnt/config/rtorrent", volume="/mnt/pve/hot/config/rtorrent"},
  ]
}

module "plex_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  os = "ubuntu-20.04-standard_20.04-1_amd64.tar.gz"

  name     = "plex"
  ip       = "192.168.47.31"
  cores    = 10
  memory   = 3072
  disksize = 3
  mounts = [
    {mp="/mnt/config/plex", volume="/mnt/pve/hot/config/plex"},
    {mp="/mnt/media", volume="/mnt/pve/cold/public/media"},
  ]
}

module "sonarr_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  os = "ubuntu-20.04-standard_20.04-1_amd64.tar.gz"

  name     = "sonarr"
  ip       = "192.168.47.32"
  memory   = 512
  mounts = [
    {mp="/mnt/config/sonarr", volume="/mnt/pve/hot/config/sonarr"},
    {mp="/mnt/downloads",     volume="/mnt/pve/cold/public/downloads"},
    {mp="/mnt/media",         volume="/mnt/pve/cold/public/media"},
  ]
}

module "radarr_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  os = "ubuntu-20.04-standard_20.04-1_amd64.tar.gz"

  name     = "radarr"
  ip       = "192.168.47.33"
  memory   = 512
  mounts = [
    {mp="/mnt/config/radarr", volume="/mnt/pve/hot/config/radarr"},
    {mp="/mnt/downloads",     volume="/mnt/pve/cold/public/downloads"},
    {mp="/mnt/media",         volume="/mnt/pve/cold/public/media"},
  ]
}

module "jackett_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  os = "ubuntu-20.04-standard_20.04-1_amd64.tar.gz"

  name     = "jackett"
  ip       = "192.168.47.34"
  memory   = 512
  disksize = 3
  mounts = [
    {mp="/mnt/config/jackett", volume="/mnt/pve/hot/config/jackett"},
    {mp="/mnt/downloads",      volume="/mnt/pve/cold/public/downloads"},
    {mp="/mnt/media",          volume="/mnt/pve/cold/public/media"},
  ]
}

module "flexget_container" {
  source = "./modules/container"
  ssh_public_keys = var.proxmox_pub_keys

  providers = {
    proxmox = proxmox
  }

  os = "ubuntu-20.04-standard_20.04-1_amd64.tar.gz"

  name     = "flexget"
  ip       = "192.168.47.35"
  mounts = [
    {mp="/mnt/config/flexget", volume="/mnt/pve/hot/config/flexget"},
    {mp="/mnt/downloads",      volume="/mnt/pve/cold/public/downloads"},
    {mp="/mnt/media",          volume="/mnt/pve/cold/public/media"},
  ]
}