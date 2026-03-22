# !/bin/bash

# ============================================================
# Log in and get root access
# ============================================================
ssh natasha@ststor01
sudo su -

# ============================================================
# Navigate and Set Up Git
# ============================================================
cd /usr/src/kodekloudrepos/apps

git config --global --add safe.directory /usr/src/kodekloudrepos/apps
git config --global user.name "natasha"
git config --global user.email "natasha@stratos.com"

# ============================================================
# The Cherry-Pick Magic
# ============================================================
# Ensure you are on the master branch
git checkout master

# Find the exact commit hash and cherry-pick it automatically
HASH=$(git log --all --grep="Update info.txt" --format="%h")
git cherry-pick $HASH

# ============================================================
# Push
# ============================================================
git push origin master