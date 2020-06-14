# Smarthome

## Proxmox host setup

- Setup storage
    - hot
    - cold
- Setup a Debian 9 cloud image
- Download Ubuntu 19.10 and Debian 9 LXC templates
    - `pveam available`
    - `pveam download local ubuntu-19.10-standard_19.10-1_amd64.tar.gz`
- Import a ssh key to proxmox host, use same key as var to terraform
- The very first VPN route import to proxmox probably wont take, needs a reboot
- Put `mkdir 0` for hot/cold storage in `/etc/pve/storage.cfg`
- May need to set open permissions on mounted directories for unpriveledged containers
- Don't let windows fool you with bad cached creds `net use /delete \\FILES` 
- Pass the usbdevice through to the home vm `qm set 10010 -usb0 host=10c4:8a2a` (reboot)
- Set DNS under the proxmox node or nothing can get to the internet
- `qrencode -t ansiutf8 < /etc/wireguard/jphone.conf`
- Add a vpn backroute to the gateway
- Forward ports: `51337 -> 186` and `51820 -> 3`

My Proxmox host is installed onto a small ssd drive. This leaves only ~150g of space in local-lvm. I have used the raid card to take ~100g from hot storage and use it for virtual disks.

### DNS

https://dns.he.net/docs.html
curl "https://dyn.dns.he.net/nic/update" -d "hostname=dyn.example.com" -d "password=password"

## Plex and friends

Settings to minimize transcoding:

```
1080p and below
Container = MP4
Video = h.264
Audio = AC3 / ACC

4K
Container = MP4
Video = h.265
Audio AC3
```

### rTorrent

- Enable autounpacking
- Create an AutoTools AutoCopy for filter `/sports\/.*/`, path of `/mnt/media` and add the label and name to path

### Sonarr / Radarr

- Add rTorrent as a Download Client
    - Host: `torrents.pintail`
    - Port: `80`
    - Url Path: `RPC2`
    - Category: `tv-sonarr` / `radarr`
- Add h264/h265 restrictions under Indexers Advanced Settings
    - Create a rule for each transcoding type mentioned above
    - Use `h264 h.264 x264` for h264
    - Use `h265 h.265 hevc x265` for h265
- Add Jackett Torznab url to indexers
    - Use apikey from Jackett

### Jackett

- Add tracker to Jackett

