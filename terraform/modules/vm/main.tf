# Variables

variable "name" {
  type = string
}

variable "vmid" {
  type    = number
  default = 0
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

variable "provisioner" {
  type    = string
  default = ""
}

locals {
  vmid = (var.vmid == 0 ? format("1%04s", element(split(".", var.ip), 3)) : var.vmid)
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
    type     = "scsi"
    storage  = "vdisk"
    iothread = true
    storage_type = "lvm"
  }

  ipconfig0 = "ip=${var.ip}/24,gw=192.168.47.1"
  sshkeys   = var.ssh_public_keys

  provisioner "local-exec" {
    command = var.provisioner
  }

  lifecycle {
    ignore_changes = [
      bootdisk,
      scsihw,
      disk
    ]
  }
}
