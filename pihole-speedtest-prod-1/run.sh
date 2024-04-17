#!/bin/bash

# Debian 4GB - (pihole-speedtest) setup script - pve thincentre {101}

#> systemctl mask ssh.socket && systemctl mask sshd.socket && systemctl disable sshd 
#> apt update -y && apt install curl gnupg -y && apt full-upgrade -y && reboot
#> chmod +x /opt/dreamcast/* && cd /opt/dreamcast && ./run.sh

# --- Install Docker & Docker Compose 
curl -sSL https://get.docker.com/ | sh && apt install docker-compose -y

# --- Addons
rm -rf /etc/update-motd.d/* && rm -rf /etc/motd && 
wget https://raw.githubusercontent.com/cityplug/copilot/main/10-uname -O /etc/update-motd.d/10-uname && chmod +x /etc/update-motd.d/10-uname

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf

#--
systemctl enable docker 
docker-compose --version && docker --version
docker network create pihole.internal
docker network create speedtest.internal
cd /root && docker-compose up -d
docker ps
docker-compose logs -f

#--------------------------------------------------------------------------------
reboot