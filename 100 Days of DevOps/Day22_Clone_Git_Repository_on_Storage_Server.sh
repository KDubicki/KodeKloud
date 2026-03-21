# !/bin/bash

# Storage Server
ssh natasha@ststor01

# Move to the target directory
cd /usr/src/kodekloudrepos

# Clone the repository
git clone /opt/*.git

# Verify
ls -la