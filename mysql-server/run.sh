#!/bin/bash

# Debian 8GB - (mysql-server-prod-1) setup script - pve thincentre {101}

#> systemctl mask ssh.socket && systemctl mask sshd.socket && systemctl disable sshd && systemctl enable ssh && sed -i '15i\Port 4792\n' /etc/ssh/sshd_config
#> apt update -y && apt install git curl gnupg -y && apt full-upgrade -y && apt autoremove && reboot
#> cd /opt && git clone https://github.com/cityplug/prod-1 && mv /opt/prod-1/pihole-prod-1 /opt/pihole-prod-1
#> chmod +x /opt/pihole-prod-1/* && cd /opt/pihole-prod-1 && ./run.sh

# --- Download the public key, convert from ASCII to GPG format
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y

# --- Addons
rm -rf /etc/update-motd.d/* && rm -rf /etc/motd && 
wget https://raw.githubusercontent.com/cityplug/prod-1/main/10-uname -O /etc/update-motd.d/10-uname && chmod +x /etc/update-motd.d/10-uname

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf

#--
systemctl enable docker 
docker-compose --version && docker --version
cd /opt/pihole-prod-1/ && docker-compose up -d && docker ps
docker-compose logs -f

#--------------------------------------------------------------------------------
reboot

# --- Install Docker & Docker Compose 
#curl -sSL https://get.docker.com/ | sh && apt install docker-compose -y