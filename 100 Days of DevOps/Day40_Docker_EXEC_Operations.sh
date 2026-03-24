# !/bin/bash

# =================================================================
# Log in
# =================================================================
ssh banner@stapp03
sudo su -

# =================================================================
# Install Apache Inside the Container
# =================================================================
# Update the apt repository inside the container
docker exec kkloud apt-get update
# Install apache2 (the -y flag auto-confirms the installation)
docker exec kkloud apt-get install -y apache2

# =================================================================
# Change the Listening Port
# =================================================================
docker exec kkloud sed -i 's/Listen 80/Listen 8088/g' /etc/apache2/ports.conf

# =================================================================
# Start the Service and Verify
# =================================================================
# Start the apache2 service inside the container
docker exec kkloud service apache2 start
# Verify that it is running and listening on port 8088
docker exec kkloud service apache2 status