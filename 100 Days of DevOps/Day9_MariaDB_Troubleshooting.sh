# !/bin/bash

# Check
sudo systemctl status mariadb

# Create the missing data directory
sudo mkdir -p /var/lib/mysql

# Fix Ownership and Permissions
sudo chown -R mysql:mysql /var/lib/mysql
sudo chmod 755 /var/lib/mysql

# Initialize Database System Tables
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# Start and Enable the Service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Verification
sudo systemctl status mariadb --no-pager