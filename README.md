# Smarthome

## Proxmox host setup

- Setup storage
    - hot
    - cold
- Setup a Debian 9 cloud image
- Download Ubuntu 19.10 and Debian 9 LXC templates
- Generate a key and pass it to terraform

My Proxmox host is installed onto a small ssd drive. This leaves only ~150g of space in local-lvm. I have used the raid card to take ~100g from hot storage and use it for virtual disks.