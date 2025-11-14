#!/bin/bash
set -ex

sudo systemctl restart corosync 
sudo systemctl restart pvedaemon 
sudo systemctl restart pvestatd 
sudo systemctl restart pve-cluster 
sudo systemctl restart pveproxy 
# restart new nftables based firewall service
sudo systemctl restart proxmox-firewall
# restart the legacy iptables based firewall service
# sudo systemctl restart pve-firewall
