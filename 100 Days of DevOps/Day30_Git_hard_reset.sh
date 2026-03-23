# !/bin/bash

# =================================================================
# Log in and get root access:
# =================================================================
ssh natasha@ststor01
sudo su -

# =================================================================
# Navigate to the repository and secure
# =================================================================
cd /usr/src/kodekloudrepos/apps
git config --global --add safe.directory /usr/src/kodekloudrepos/apps

# =================================================================
# Reset the history and force push
# =================================================================
git log --oneline
git reset --hard efd39df
git push -f origin master

