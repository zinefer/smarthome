# Module Variables

variable "name" {
  type = string
}

variable "vmid" {
  type     = number
  default  = 0
}

variable "ip" {
  type    = string
  default = "dhcp"
}

variable "os" {
  type = string
  default = "ubuntu-19.10-standard_19.10-1_amd64.tar.gz"
}

variable "disksize" {
  type    = string
  default = "2"
}

variable "cores" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "256"
}

variable "swap" {
  type    = string
  default = "256"
}

variable "start" {
  type    = bool
  default = true
}

variable "ssh_public_keys" {
  type    = string
}

locals {
  ip   = (var.ip == "dhcp" ? var.ip : "${var.ip}/32")
  vmid = (var.vmid == 0 && var.ip != "dhcp" ? format("1%04s", element(split(".", var.ip), 3)) : var.vmid)
}

# Providers

provider "proxmox" { }

## Provision Container

resource "proxmox_lxc" "container" {
  target_node  = "proxmox"
  ostemplate   = "local:vztmpl/${var.os}"
  storage      = "local-lvm"
  unprivileged = true
  
  network {
    gw     = "192.168.1.1"
    name   = "eth0"
    ip     = local.ip
    ip6    = "dhcp"
    bridge = "vmbr0"
    firewall = true
  }

  ssh_public_keys = var.ssh_public_keys

  hostname = var.name
  vmid     = local.vmid
  cores    = var.cores
  memory   = var.memory
  swap     = var.swap
  start    = var.start
  rootfs   = "vdisk:${var.disksize}"
  cpuunits = 0

  lifecycle {
    ignore_changes = [
      start,
      ostemplate,
      ssh_public_keys,
      storage,
      ostype,
      password,
      network,
      rootfs
    ]
  }
}

# Outputs

output "ip" {
  value = var.ip
}