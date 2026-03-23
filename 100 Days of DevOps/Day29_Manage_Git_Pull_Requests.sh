# !/bin/bash

ssh max@ststor01
cd ~/story-blog
git log

# ==============================================================
# Create the Pull Request (Gitea UI as Max)
# ==============================================================
"""
Username: max
Password: Max_pass123
Click on the story-blog repository on your dashboard.
Click the Pull Requests tab near the top.
Click the green New Pull Request button.
Base (Left side): Set this to master (This is the destination where the code is going).
Compare (Right side): Set this to story/fox-and-grapes (This is the source you are pulling from).
Once the branches are set correctly, click the green New Pull Request button just below them.
In the Title box, type exactly: Added fox-and-grapes story
Click Create Pull Request at the bottom.
On the right side of the screen, find the Reviewers section. Click the ⚙️ gear icon, click on tom to assign him, and click away to close the dropdown.
Click your profile picture in the top right and click Sign Out.
"""

# ==============================================================
# Approve and Merge (Gitea UI as Tom)
# ==============================================================
"""
Username: tom
Password: Tom_pass123
Click on the story-blog repository.
Go to the Pull Requests tab.
Click on the Added fox-and-grapes story pull request.
Click the green Merge Pull Request button.
Click Create Merge Commit to finalize it.
"""