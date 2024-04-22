#!/bin/bash

# Debian 3GB - (homepage-prod-1) setup script - pve thincentre {102}

#> systemctl mask ssh.socket && systemctl mask sshd.socket && systemctl disable sshd && apt update -y && apt install git curl gnupg -y && apt full-upgrade -y && reboot
#> cd /opt && git clone https://github.com/cityplug/prod-1 && mv /opt/prod-1/homepage-prod-1 /opt/homepage-prod-1 &&chmod +x /opt/homepage-prod-1/* && cd /opt/homepage-prod-1 && ./run.sh

# --- Install Docker & Docker Compose 
curl -sSL https://get.docker.com/ | sh && apt install docker-compose -y

# --- Addons
rm -rf /etc/update-motd.d/* && rm -rf /etc/motd && 
wget https://raw.githubusercontent.com/cityplug/prod-1/main/homepage-prod-1/10-uname -O /etc/update-motd.d/10-uname && chmod +x /etc/update-motd.d/10-uname

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf

adduser focal
usermod -aG docker focal
#--
systemctl enable docker 
docker-compose --version && docker --version
cd /opt/homepage-prod-1/ && docker-compose up -d
docker ps
docker-compose logs -f

#--------------------------------------------------------------------------------
reboot

# --- Build Homepage
#docker stop homepage
#rm -rf /opt/appdata/homepage/
#mv /opt/homepage/config /env/appdata/homepage
#docker start homepage