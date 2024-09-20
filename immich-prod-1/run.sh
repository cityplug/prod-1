#!/bin/bash

# Debian 8GB/1Core/512MB - (immich-prod-1) setup script - pve thinkstation {1000}

#> systemctl mask ssh.socket && systemctl mask sshd.socket && systemctl disable sshd && systemctl enable ssh && sed -i '15i\Port 4792\n' /etc/ssh/sshd_config
#> apt update -y && apt install git curl gnupg ufw software-properties-common -y && apt full-upgrade -y && apt autoremove && mkdir -p /opt/appdata && reboot
#> cd /opt && git clone https://github.com/cityplug/prod-1 && mv /opt/prod-1/immich-prod-1 /opt/immich-prod-1
#> chmod +x /opt/immich-prod-1/* && cd /opt/immich-prod-1 && ./run.sh

# --- Install Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update && apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# --- Install Docker-Compose
wget https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-aarch64 -O /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose && apt install docker-compose -y

# --- Addons
rm -rf /etc/update-motd.d/* && rm -rf /etc/motd && 
wget https://raw.githubusercontent.com/cityplug/prod-1/main/10-uname -O /etc/update-motd.d/10-uname && chmod +x /etc/update-motd.d/10-uname

#--
systemctl enable docker 
docker-compose --version && docker --version
docker run -d -p 9000:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/appdata/portainer:/data portainer/portainer-ce:latest
cd /opt/immich-prod-1/ && docker compose up -d && docker ps
docker-compose logs -f

# --- Security Addons
adduser focal && groupadd ssh-users
usermod -aG ssh-users,docker focal
sed -i '15i\AllowGroups ssh-users\n' /etc/ssh/sshd_config

# --- Firewall Rules 
ufw deny 22
ufw allow 4792

ufw logging on
ufw enable
ufw status

#--------------------------------------------------------------------------------
sleep 10
reboot

