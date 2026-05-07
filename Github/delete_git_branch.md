# Delete Git Branch

## Objective
The Nautilus development team requested repository maintenance on the Storage Server (`ststor01`). During recent testing, several test branches were created within the `media` project repository. The objective is to clean up the repository by permanently deleting a specific unused local branch named `xfusioncorp_media`.

## Environment Details
* **Target Node:** Storage Server (`ststor01`)
* **User:** `natasha`
* **Target Repository:** `/usr/src/kodekloudrepos/media`
* **Branch to Delete:** `xfusioncorp_media`

---

## Execution Steps

### 1. Connect to the Storage Server
Established an SSH connection to the target server from the Jump Host.

    ssh natasha@ststor01
    # Authenticated using infrastructure credentials

### 2. Navigate to the Target Repository
Changed the current directory to the locally cloned Git repository.

    cd /usr/src/kodekloudrepos/media

### 3. Verify and Change Current Branch
Before a branch can be deleted, it cannot be the active working tree (currently checked out). 
*Note: `sudo` is used here preemptively to avoid any `dubious ownership` or permission denied errors if the cloned repository is owned by the `root` user.*

    # Check current active branch
    sudo git branch

    # Switch off the target branch to the main/master branch
    sudo git checkout master

### 4. Delete the Target Branch
Executed the branch deletion command using the `-d` flag. 

    sudo git branch -d xfusioncorp_media

*Troubleshooting Note: If Git prevents the deletion because the branch has unmerged changes (a common scenario for abandoned test branches), use the uppercase `-D` flag to force the deletion:*

    sudo git branch -D xfusioncorp_media

**Verification:**
The terminal output confirmed the successful deletion of the branch:
`Deleted branch xfusioncorp_media (was <commit-hash>).`