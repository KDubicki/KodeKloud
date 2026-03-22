# !/bin/bash

# Storage Server
ssh natasha@ststor01
sudo su -

# ========================================================================
# Navigate and Configure Git
# ========================================================================
cd /usr/src/kodekloudrepos/apps

# Bypass the "dubious ownership" security check
git config --global --add safe.directory /usr/src/kodekloudrepos/apps

# Tell Git who is making the commit
git config --global user.name "natasha"
git config --global user.email "natasha@stratos.com"

# ========================================================================
# Branch, Copy, and Commit
# ========================================================================
# Ensure you are on master
git checkout master

# Create and switch to the new 'xfusion' branch
git checkout -b xfusion

# Copy the file from /tmp into your current directory
cp /tmp/index.html .

# Add and commit the file to the xfusion branch
git add index.html
git commit -m "Added index.html to xfusion branch"

# ========================================================================
# Push, Merge, and Push Again
# ========================================================================
# Push the new xfusion branch
git push origin xfusion

# Switch back to the master branch
git checkout master

# Merge the xfusion branch into master
git merge xfusion

# Push the updated master branch
git push origin master