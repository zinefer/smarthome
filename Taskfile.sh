#!/bin/bash

function install {
    # Terraform
    go get github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox
    go install github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provider-proxmox
    go get github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox
    go install github.com/Telmate/terraform-provider-proxmox/cmd/terraform-provisioner-proxmox
    # Why Terraform, why
    ln -s $(which terraform-provisioner-proxmox) ~/.terraform.d/plugins/terraform-provisioner-proxmox
    ln -s $(which terraform-provider-proxmox) ~/.terraform.d/plugins/terraform-provider-proxmox

}

function provision {
    terraform init terraform
    terraform apply terraform

}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed ins%3lR"
time ${@:-help}



