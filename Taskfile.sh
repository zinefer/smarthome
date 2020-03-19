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

    # Ansible
    ansible-galaxy install -r ansible/requirements.yml --roles-path ansible/roles
}

function provision {
    terraform init terraform
    terraform apply terraform
}

function deploy {
    ANSIBLE_CONFIG=./ansible.cfg \
    PI_ADMIN_PASSWORD=$(echo -n `terraform output admin_password` | sha256sum | awk '{printf "%s",$1 }' | sha256sum | awk '{printf "%s",$1 }') \
    ADMIN_PASSWORD=$(terraform output admin_password) \
    ansible-playbook -i ansible/hosts ansible/site.yml --vault-password-file ./pass.sh
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed ins%3lR"
time ${@:-help}



