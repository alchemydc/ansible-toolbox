#!/bin/bash
set -ex

sudo systemctl restart corosync 
sudo systemctl restart pvedaemon 
sudo systemctl restart pvestatd 
sudo systemctl restart pve-cluster 
sudo systemctl restart pveproxy 
