#!/bin/bash

# Debian 8GB - (speedscale-prod-1) setup script - pve thincentre {103}

#> systemctl mask ssh.socket && systemctl mask sshd.socket && systemctl disable sshd && systemctl enable ssh && sed -i '15i\Port 4792\n' /etc/ssh/sshd_config
#> apt update -y && apt install git curl gnupg -y && apt full-upgrade -y && apt autoremove && reboot
#> cd /opt && git clone https://github.com/cityplug/prod-1 && mv /opt/prod-1/speedscale-prod-1 /opt/speedscale-prod-1
#> chmod +x /opt/speedscale-prod-1/* && cd /opt/speedscale-prod-1 && ./run.sh

# --- Install Docker Official GPG key to Apt sources
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

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf

#--
systemctl enable docker 
docker-compose --version && docker --version
docker network create speedtest
cd /opt/speedscale-prod-1/ && docker-compose up -d && docker ps
docker-compose logs -f

# --- Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --advertise-routes=192.168.31.0/24
#--------------------------------------------------------------------------------
reboot

[host]
echo "
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file" >> /etc/pve/lxc/103.conf