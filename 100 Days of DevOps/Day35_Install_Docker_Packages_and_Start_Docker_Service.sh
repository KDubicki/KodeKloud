# !/bin/bash

# =================================================================
# Log in
# =================================================================
ssh banner@stapp03
sudo su -

# =================================================================
# Add the Official Docker Repository
# =================================================================
# Install the yum-utils package
yum install -y yum-utils
# Add the official Docker CE repository
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# =================================================================
# Install Docker CE and Docker Compose
# =================================================================
yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# =================================================================
# Initiate and Enable the Service
# =================================================================
# Start the Docker service
systemctl start docker
# Enable it so it survives a server reboot
systemctl enable docker

# =================================================================
# Verify
# =================================================================
# Check if Docker is running
systemctl status docker
# Verify Docker Compose is installed
docker compose version