# Variables

variable "name" {
  type = string
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

# Providers

provider "proxmox" { }

resource "proxmox_vm_qemu" "vm" {
  name        = var.name
  target_node = "proxmox"
  clone       = "debian-cloud-image"
  memory      = var.memory # proxmox_vm_qemu defaults to 512

  disk {
    id       = 0
    size     = var.disksize
    type     = "virtio"
    storage  = "vdisk"
    iothread = true
    storage_type = "lvm"
  }

  ipconfig0 = "ip=${var.ip}/24,gw=192.168.1.1"
  sshkeys   = var.ssh_public_keys
}
