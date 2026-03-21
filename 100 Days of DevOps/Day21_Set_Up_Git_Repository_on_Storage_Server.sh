# !/bin/bash

# Storage Server
ssh natasha@ststor01
sudo su -

# Install Git
yum install -y git

# Create the Bare Repository
git init --bare /opt/apps.git

# Verify
ls -l /opt/apps.git