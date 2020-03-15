# Smarthome

## Proxmox host setup

- Setup storage
    - hot
    - cold
- Setup a Debian 9 cloud image
- Download Ubuntu 19.10 and Debian 9 LXC templates
- Import a ssh key to proxmox host, use same key as var to terraform
- The very first VPN route import to proxmox probably wont take, needs a reboot
- Put `mkdir 0` for hot/cold storage in `/etc/pve/storage.cfg`

My Proxmox host is installed onto a small ssd drive. This leaves only ~150g of space in local-lvm. I have used the raid card to take ~100g from hot storage and use it for virtual disks.

