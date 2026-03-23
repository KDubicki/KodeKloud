# !/bin/bash

# =================================================================
# Log in and get root access
# =================================================================
ssh natasha@ststor01
sudo su -

# =================================================================
# Navigate and Set Up Git
# =================================================================
cd /usr/src/kodekloudrepos/blog

git config --global --add safe.directory /usr/src/kodekloudrepos/blog
git config --global user.name "natasha"
git config --global user.email "natasha@stratos.com"

# =================================================================
# The Rebase
# =================================================================
# 1. Switch to the feature branch
git checkout feature
# 2. Rebase it with the master branch
git rebase master

# =================================================================
# Force Push
# =================================================================
# Force push the rebased feature branch to the origin server
git push -f origin feature
