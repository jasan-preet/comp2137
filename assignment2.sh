#!/bin/bash

# Network Interface Configuration
echo "Configuring network interface..."
cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml >/dev/null
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 192.168.16.21/24
      gateway4: 192.168.16.2
      nameservers:
          addresses: [192.168.16.2]
          search: [home.arpa, localdomain]
EOF
sudo netplan apply

# Update /etc/hosts File
echo "Updating /etc/hosts file..."
sudo sed -i '/server1/d' /etc/hosts
echo "192.168.16.21 server1" | sudo tee -a /etc/hosts >/dev/null

# Install required software
echo "Installing apache2 and squid..."
sudo apt-get update
sudo apt-get install -y apache2 squid

# Firewall Configuration
echo "Configuring firewall using ufw..."
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on mgmt to any port 22
sudo ufw allow in on eth0 to any port 80
sudo ufw allow in on eth0 to any port 3128
sudo ufw --force enable

# User Account Creation
echo "Creating user accounts..."
sudo useradd -m -s /bin/bash dennis
echo "dennis ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/dennis >/dev/null
sudo mkdir -p /home/dennis/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" | sudo tee -a /home/dennis/.ssh/authorized_keys >/dev/null
sudo chown -R dennis:dennis /home/dennis/.ssh
sudo chmod 700 /home/dennis/.ssh
sudo chmod 600 /home/dennis/.ssh/authorized_keys

# Output success message
echo "Configuration completed successfully."
