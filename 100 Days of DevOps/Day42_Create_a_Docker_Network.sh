# !/bin/bash

# =================================================================
# Log in
# =================================================================
ssh banner@stapp03
sudo su -

# =================================================================
# Create the Macvlan Network
# =================================================================
docker network create -d macvlan --subnet=10.10.1.0/24 --ip-range=10.10.1.0/24 media

# =================================================================
# Verify
# =================================================================
# Check that 'media' is in the list and shows 'macvlan' as the driver
docker network ls
# Inspect the network to verify the subnet and ip-range
docker network inspect media
