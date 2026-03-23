# !/bin/bash

# =================================================================
# Log in
# =================================================================
ssh max@ststor01

# =================================================================
# Go to the repo and pull changes
# =================================================================
cd ~/story-blog
# Pull the latest changes from the server
git pull origin master

# =================================================================
# Show broken file
# =================================================================
cat story-index.txt

# =================================================================
# Fix the File
# =================================================================
cat << 'EOF' > story-index.txt
1. The Lion and the Mouse
2. The Frogs and the Ox
3. The Fox and the Grapes
4. The Donkey and the Dog
EOF

# =================================================================
# Mark as Resolved and Commit
# =================================================================
# Add the fixed file to the staging area
git add story-index.txt
# Commit the resolved merge
git commit -m "Resolved merge conflict and fixed typo"

# =================================================================
# Push
# =================================================================
git push origin master