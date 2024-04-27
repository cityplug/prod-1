#!/bin/bash

# Debian 8GB - (mysql-server-prod-1) setup script - pve thincentre {501}

#> systemctl mask ssh.socket && systemctl mask sshd.socket && systemctl disable sshd && systemctl enable ssh && sed -i '15i\Port 4792\n' /etc/ssh/sshd_config
#> apt update -y && apt install git curl gnupg software-properties-common -y && apt full-upgrade -y && apt autoremove && reboot
#> cd /opt && git clone https://github.com/cityplug/prod-1 && mv /opt/prod-1/mysql-server-prod-1 /opt/mysql-server-prod-1
#> chmod +x /opt/mysql-server-prod-1/* && cd /opt/mysql-server-prod-1 && ./run.sh

# --- Download the public key, convert from ASCII to GPG format
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list

# --- Addons
rm -rf /etc/update-motd.d/* && rm -rf /etc/motd && 
wget https://raw.githubusercontent.com/cityplug/prod-1/main/10-uname -O /etc/update-motd.d/10-uname && chmod +x /etc/update-motd.d/10-uname

# --- Install SQL Server
apt install mysql-server -y
systemctl start mysql.service

#--
mysql_secure_installation
mysql -u root -p

#--------------------------------------------------------------------------------
reboot
