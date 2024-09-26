#!/bin/bash

# Debian 8GB/1Core/512MB - (ddm-prod) setup script - pve thinkstation {2000}

#> systemctl mask ssh.socket && systemctl mask sshd.socket && systemctl disable sshd && systemctl enable ssh && sed -i '15i\Port 4792\n' /etc/ssh/sshd_config
#> apt update -y && apt install git ufw curl ca-certificates gnupg -y && apt full-upgrade -y && apt autoremove && reboot
#> cd /opt && git clone https://github.com/cityplug/prod-1 && mv /opt/prod-1/docker-deployment-prod /opt/thinkstation && rm -r /opt/prod-1/
#> chmod +x /opt/thinkstation/* && cd /opt/thinkstation && ./run_docker_deployment.sh

# --- Install Docker Official GPG key to Apt sources:
read -p "Would you like to install Docker? (Y/N): " response
if [[ "$response" == "y" ]]; then
    # Check if Docker is already installed
    if command -v docker &> /dev/null; then
        echo "Docker is already installed."
        # Ask if the user wants to update Docker
        read -p "Would you like to update Docker? (Y/N): " update_response
        if [[ "$update_response" == "y" ]]; then
            echo "Updating Docker..."
            # Set up Docker repository and update Docker
            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
            chmod a+r /etc/apt/keyrings/docker.asc
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y
            echo "Docker has been updated."
        else
            echo "Docker update skipped."
        fi
    else
        # Docker is not installed, proceed with installation
        echo "Installing Docker..."
        # Set up Docker repository
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y 
        echo "Docker has been installed."
    fi
else
    echo "Docker installation skipped."
fi

# --- Addons
rm -r /etc/update-motd.d/* && rm -r /etc/motd && 
wget https://raw.githubusercontent.com/cityplug/prod-1/main/10-uname -O /etc/update-motd.d/10-uname && chmod +x /etc/update-motd.d/10-uname

echo "
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf
sysctl -p

# --- Docker Build Services
systemctl enable docker 
docker-compose --version && docker --version
# Check if 'frontend' network exists, if not, create it
if [[ "$(docker network ls | grep frontend)" ]]; then
  echo "frontend network already exists."
else
  echo "Creating frontend network..."
  docker network create frontend
fi
# Check if 'backend' network exists, if not, create it
if [[ "$(docker network ls | grep backend)" ]]; then
  echo "backend network already exists."
else
  echo "Creating backend network..."
  docker network create backend
fi
docker run -d -p 9000:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/thinkstation/appdata/portainer:/data portainer/portainer-ce:2.21.2-alpine
docker compose up -d && docker ps
docker-compose logs -f

# --- Security Addons 
adduser focal
groupadd ssh-users
usermod -aG ssh-users,docker focal
sed -i '15i\AllowGroups ssh-users\n' /etc/ssh/sshd_config
ufw allow from 10.1.1.0/24 to any
ufw deny 22
ufw allow 4792
ufw default deny incoming
ufw default allow outgoing
ufw allow 85 #homer
ufw allow 9000 #portainer
ufw logging on
read -p "Would you like to enable UFW? (Y/N): " response
if [[ "$response" == "y" ]]; then
    echo "enabling UFW..."
    ufw enable
elif [[ "$response" == "n" ]]; then
    echo "UFW not enabled."
else
    echo "Invalid response. Please enter Y or N."
fi
ufw status verbose

# --- Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --advertise-routes=192.168.41.0/24 --advertise-exit-node

#--------------------------------------------------------------------------------
sleep 10
reboot

# --- Build UDMS
#docker stop UDMS
#rm -rf /opt/appdata/UDMS/
#mv /opt/UDMS/config /env/appdata/UDMS
#docker start UDMS