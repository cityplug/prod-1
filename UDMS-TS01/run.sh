#!/bin/bash

# Debian 8GB/1Core/512MB - (UDMS-prod-1) setup script - pve thinkstation {102}

#> systemctl mask ssh.socket && systemctl mask sshd.socket && systemctl disable sshd && systemctl enable ssh && sed -i '15i\Port 4792\n' /etc/ssh/sshd_config
#> apt update -y && apt install git curl ca-certificates gnupg -y && apt full-upgrade -y && apt autoremove && reboot
#> cd /opt && git clone https://github.com/cityplug/prod-1 && mv /opt/prod-1/UDMS-prod-1 /opt/UDMS-prod-1
#> chmod +x /opt/UDMS-prod-1/* && cd /opt/UDMS-prod-1 && ./run.sh

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

adduser focal docker

# --- Security Addons 
groupadd ssh-users
usermod -aG ssh-users focal
sed -i '15i\AllowGroups ssh-users\n' /etc/ssh/sshd_config
ufw deny 22
ufw allow 4792
ufw logging on
ufw enable
ufw status

#--
systemctl enable docker 
docker-compose --version && docker --version
docker network create frontend
docker network create backend
cd /opt/UDMS-prod-1/ && docker-compose up -d && docker ps
docker-compose logs -f


#--------------------------------------------------------------------------------
sleep 10
reboot

# --- Build UDMS
#docker stop UDMS
#rm -rf /opt/appdata/UDMS/
#mv /opt/UDMS/config /env/appdata/UDMS
#docker start UDMS