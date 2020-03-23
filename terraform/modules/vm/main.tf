# Variables

variable "name" {
  type = string
}

variable "vmid" {
  type     = number
  default  = 0
}

variable "ip" {
  type = string
}

variable "ssh_public_keys" {
  type = string
}

variable "disksize" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = number
  default = 256
}

variable "cores" {
  type    = string
  default = "1"
}

locals {
  vmid = (var.vmid == 0 ? format("1%04s", element(split(".", var.ip), 3)) : var.vmid)
}

# Providers

provider "proxmox" { }

resource "proxmox_vm_qemu" "vm" {
  target_node = "proxmox"
  clone       = "debian-cloud-image"
  name        = var.name
  vmid        = local.vmid
  memory      = var.memory # proxmox_vm_qemu defaults to 512
  cores       = var.cores

  disk {
    id       = 0
    size     = var.disksize
    type     = "virtio"
    storage  = "vdisk"
    iothread = true
    storage_type = "lvm"
  }

  ipconfig0 = "ip=${var.ip}/24,gw=192.168.47.1"
  sshkeys   = var.ssh_public_keys

  lifecycle {
    ignore_changes = [
      bootdisk,
      scsihw,
      disk
    ]
  }
}
