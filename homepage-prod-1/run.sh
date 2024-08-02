#!/bin/bash

# Debian 8GB/1Core/512MB - (homepage-prod-1) setup script - pve thinkstation {1000}

#> systemctl mask ssh.socket && systemctl mask sshd.socket && systemctl disable sshd && systemctl enable ssh && sed -i '15i\Port 4792\n' /etc/ssh/sshd_config
#> apt update -y && apt install git curl gnupg -y && apt full-upgrade -y && apt autoremove && reboot
#> cd /opt && git clone https://github.com/cityplug/prod-1 && mv /opt/prod-1/homepage-prod-1 /opt/homepage-prod-1
#> chmod +x /opt/homepage-prod-1/* && cd /opt/homepage-prod-1 && ./run.sh

# --- Install Docker Official GPG key to Apt sources:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y

# --- Addons
rm -rf /etc/update-motd.d/* && rm -rf /etc/motd && 
wget https://raw.githubusercontent.com/cityplug/prod-1/main/10-uname -O /etc/update-motd.d/10-uname && chmod +x /etc/update-motd.d/10-uname

#--
systemctl enable docker 
docker-compose --version && docker --version
cd /opt/homepage-prod-1/ && docker-compose up -d && docker ps
docker-compose logs -f

#--------------------------------------------------------------------------------
sleep 10
reboot

# --- Build Homepage
#docker stop homepage
#rm -rf /opt/appdata/homepage/
#mv /opt/homepage/config /env/appdata/homepage
#docker start homepage