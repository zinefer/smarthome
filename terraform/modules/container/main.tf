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

# Providers

provider "proxmox" { }

## Provision Container

resource "random_password" "container" {
  override_special = "_%@"
  length  = 16
  special = true  
}

resource "proxmox_lxc" "container" {
  target_node  = "proxmox"
  ostemplate   = "local:vztmpl/ubuntu-19.10-standard_19.10-1_amd64.tar.gz"
  storage      = "local-lvm"
  unprivileged = true
  
  network {
    gw     = "192.168.1.1"
    name   = "eth0"
    ip     = (var.ip == "dhcp" ? var.ip : "${var.ip}/32")
    ip6    = "dhcp"
    bridge = "vmbr0"
    firewall = true
  }

  password = random_password.container.result
  hostname = var.name
  vmid     = var.vmid
  cores    = var.cores
  memory   = var.memory
  swap     = var.swap
  cpuunits = 0
  rootfs   = var.disksize
  start    = var.start

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

output "password" {
  value = random_password.container.result
}