# !/bin/bash

# Storage Server
ssh natasha@ststor01
sudo su -

# Move to the Repository
cd /usr/src/kodekloudrepos/ecommerce
git config --global --add safe.directory /usr/src/kodekloudrepos/ecommerce

# Create the New Branch
git checkout master
git checkout -b xfusioncorp_ecommerce

# Verify
git branch