# !/bin/bash

# =================================================================
# Log in and get root access
# =================================================================
ssh natasha@ststor01
sudo su -

# =================================================================
# Navigate and Configure Git
# =================================================================
cd /usr/src/kodekloudrepos/media

git config --global --add safe.directory /usr/src/kodekloudrepos/media
git config --global user.name "natasha"
git config --global user.email "natasha@stratos.com"

# =================================================================
# Apply the Stash, Commit, and Push
# =================================================================
# 1. Apply the exact stash requested (Notice the quotes!)
git stash apply 'stash@{1}'

# 2. Add the newly restored files to the staging area
git add .

# 3. Commit the changes
git commit -m "Restored stashed changes from stash@{1}"

# 4. Push the changes to the remote repository
git push origin master