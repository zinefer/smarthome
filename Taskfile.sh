#!/bin/bash

function _forEachHostExec {
    hosts="ansible/hosts"
    while IFS= read -r line
    do
        [[ $line == [* ]] || [[ $line == "" ]] && continue
        pieces=($line)
        host=${pieces[0]}
        ip=${pieces[1]#*=}

        $1 $host $ip
    done < "$hosts"
}

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
    galaxy
}

function galaxy {
    ansible-galaxy install -r ansible/requirements.yml --roles-path ansible/roles
}

function clear-hosts {
    function clr {
        ssh-keygen -f ~/.ssh/known_hosts -R $1
        ssh-keygen -f ~/.ssh/known_hosts -R $2
    }
    
    _forEachHostExec clr
}

function import {    
    function imp {
        fqdn=$1
        ip=$2
        host=${fqdn%.*}

        [[ $host == "proxmox" ]] && return
        
        cat terraform/main.tf | grep "${host}_container" > /dev/null; isVm=$?

        cmd="terraform import -config terraform module.${host}_"

        if (( isVm )); then
            cmd+="vm.proxmox_vm_qemu.vm"
        else
            cmd+="container.proxmox_lxc.container"
        fi

        id="1$(printf '%04d\n' ${ip##*.})"
        cmd+=" proxmox/lxc/$id"

        $cmd
    }

    _forEachHostExec imp
}

function provision {
    terraform init terraform
    terraform apply terraform
}

function deploy {
    TARGET=${1:-site}

    ANSIBLE_CONFIG=./ansible.cfg \
    PI_ADMIN_PASSWORD=$(echo -n `terraform output admin_password` | sha256sum | awk '{printf "%s",$1 }' | sha256sum | awk '{printf "%s",$1 }') \
    ADMIN_PASSWORD=$(terraform output admin_password) \
    ansible-playbook -i ansible/hosts --vault-password-file ./pass.sh \
    ansible/$TARGET.yml \
    ansible/update-dns.yml
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | sed -En '/_/!p' | cat -n
}

TIMEFORMAT="Task completed ins%3lR"
time ${@:-help}