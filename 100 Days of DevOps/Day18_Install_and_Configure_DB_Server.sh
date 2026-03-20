# !/bin/bash

# Connect to the Database Server
ssh peter@stdb01
sudo su -

# Install and Start MariaDB
yum install -y mariadb-server
systemctl start mariadb
systemctl enable mariadb

# Access the Database Prompt
mysql

# Create the Database and User
CREATE DATABASE kodekloud_db1;
CREATE USER 'kodekloud_gem'@'localhost' IDENTIFIED BY 'ksH85UJjhb';
GRANT ALL PRIVILEGES ON kodekloud_db1.* TO 'kodekloud_gem'@'localhost';
FLUSH PRIVILEGES;


# Verify
SHOW DATABASES;