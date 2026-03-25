# !/bin/bash

# =================================================================
# Log in
# =================================================================
ssh banner@stapp03
sudo su -

# =================================================================
# Create the Directory and Compose File
# =================================================================
# 1. Create the directory
mkdir -p /opt/docker

# 2. Create the docker-compose.yml file
cat << 'EOF' > /opt/docker/docker-compose.yml
version: '3.8'
services:
  web:
    image: httpd:latest
    container_name: httpd
    ports:
      - "8087:80"
    volumes:
      - /opt/dba:/usr/local/apache2/htdocs
EOF

# =================================================================
# Spin Up the Container
# =================================================================
# 1. Navigate to the directory containing the file
cd /opt/docker
# 2. Start the container
docker compose up -d

# =================================================================
# Verify
# =================================================================
docker ps