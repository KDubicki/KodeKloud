# !/bin/bash

# ============================================================
# Log in and get root access
# ============================================================
ssh natasha@ststor01
sudo su -

# ============================================================
# Navigate and set up Git
# ============================================================
cd /usr/src/kodekloudrepos/beta

git config --global --add safe.directory /usr/src/kodekloudrepos/beta
git config --global user.name "natasha"
git config --global user.email "natasha@stratos.com"

# ============================================================
# Add the remote and verify it
# ============================================================
git remote add dev_beta /opt/xfusioncorp_beta.git

# Optional: Run this just to visually confirm it was added!
git remote -v

# ============================================================
# Copy the file, commit, and push
# ============================================================
git checkout master

cp /tmp/index.html .

git add index.html
git commit -m "Added index.html for dev_beta update"

git push dev_beta master