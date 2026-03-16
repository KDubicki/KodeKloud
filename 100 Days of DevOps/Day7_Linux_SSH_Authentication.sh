# !/bin/bash

# Generate the SSH Key
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Copy the Key to the App Servers
ssh-copy-id tony@stapp01
ssh-copy-id tony@stapp01
ssh-copy-id banner@stapp03