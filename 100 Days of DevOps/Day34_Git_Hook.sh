# !/bin/bash

# =================================================================
# Log in
# =================================================================
ssh natasha@ststor01

# =================================================================
# Create the Server-Side Hook
# =================================================================
# 1. Go to the remote repository's hook folder
cd /opt/media.git/hooks

# 2. Create the post-update script
cat << 'EOF' > post-update
#!/bin/bash
for ref in "$@"; do
    if [ "$ref" == "refs/heads/master" ]; then
        git tag release-$(date +%Y-%m-%d) master
    fi
done
EOF

# 3. Make the script executable so Git can actually run it
chmod +x post-update

# =================================================================
# Merge the Local Branches
# =================================================================
# 1. Navigate to the local clone
cd /usr/src/kodekloudrepos/media

# 2. Ensure your Git identity is set (just in case!)
git config --global user.name "natasha"
git config --global user.email "natasha@stratos.com"

# 3. Make sure you are on the master branch
git checkout master

# 4. Merge the feature branch into master
git merge feature

# =================================================================
# Push and Trigger the Hook
# =================================================================
git push origin master

# =================================================================
# Verify
# =================================================================
git ls-remote --tags origin