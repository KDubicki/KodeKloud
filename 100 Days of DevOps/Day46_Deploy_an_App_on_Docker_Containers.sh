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
mkdir -p /opt/itadmin

# 2. Write the docker-compose.yml file
cat << 'EOF' > /opt/itadmin/docker-compose.yml
version: '3.8'

services:
  web:
    image: php:apache
    container_name: php_blog
    ports:
      - "6400:80"
    volumes:
      - /var/www/html:/var/www/html
    depends_on:
      - db

  db:
    image: mariadb:latest
    container_name: mysql_blog
    ports:
      - "3306:3306"
    volumes:
      - /var/lib/mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: complexRootPassword123!
      MYSQL_DATABASE: database_blog
      MYSQL_USER: bloguser
      MYSQL_PASSWORD: complexBlogPassword123!
EOF


# =================================================================
# Test the Deployment
# =================================================================
# 1. Navigate to the directory
cd /opt/itadmin

# 2. Spin up the stack in the background
docker compose up -d

# =================================================================
# Verify
# =================================================================
# Check that both containers are running and ports are mapped
docker ps

# Test the web service using curl
curl localhost:6400/