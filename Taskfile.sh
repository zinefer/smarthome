#!/bin/bash

function _forEachHostExec {
    hosts="ansible/hosts"
    while IFS= read -r line
    do
        [[ $line == [* ]] || [[ $line == "" ]] && continue
        pieces=($line); host=${pieces[0]%.*}; ip=${pieces[1]#*=};
        $1 $host $ip
    done < $hosts
}

function _isVm {
    cat terraform/main.tf | grep "${1}_vm" > /dev/null
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

function vault {
    file="ansible/group_vars/$1.yml"
    [ ! -f $file ] && file="ansible/host_vars/$1.yml"
    [ -f $file ] && ansible-vault edit $file --vault-password-file ./pass.sh && exit
    ansible-vault create $file --vault-password-file ./pass.sh
}

function clear-hosts {
    function clr {
        ssh-keygen -f ~/.ssh/known_hosts -R $1.pintail
        ssh-keygen -f ~/.ssh/known_hosts -R $2
    }
    
    _forEachHostExec clr
}

function import {    
    function imp {
        host=$1
        ip=$2

        [[ $host == "proxmox" ]] && return
        
        id="1$(printf '%04d\n' ${ip##*.})"
        
        grep -q $id terraform.tfstate && return

        if (_isVm $host); then
            type="vm.proxmox_vm_qemu.vm"
        else
            type="container.proxmox_lxc.container"
        fi

        terraform import -config terraform module.${host}_${type} proxmox/lxc/${id}
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
    ansible-playbook -i ansible/hosts --vault-password-file ./pass.sh \
    ansible/$TARGET.yml \
    ansible/update-dns.yml
}

function destroy {
    host=${1?}
    (_isVm $host) && type="vm" || type="container"
    terraform destroy -target=module.${host}_${type} terraform
}

function ssh {
    host=${1?}
    (_isVm $host) && user="debian" || user="root"
    /usr/bin/ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${user}@${host}.pintail
}

function renew {
    TARGET=${1?}
    destroy $TARGET
    provision
    import
    deploy $TARGET
}

function clear-pwd {
    echo RELOADAGENT | gpg-connect-agent
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | sed -En '/^_/!p' | cat -n
}

TIMEFORMAT="Task completed ins%3lR"
time ${@:-help}