# Update Git Repository with Sample HTML File

## Objective
The Nautilus development team required the addition of a sample `index.html` file to a recently created Git repository on the Storage Server (`ststor01`). This task involved a secure file transfer across nodes, handling Linux permission restrictions, and executing a standard Git workflow (Add, Commit, Push) under elevated privileges due to repository ownership constraints.

## Environment Details
* **Source Node:** Jump Host
* **Target Node:** Storage Server (`ststor01`)
* **User:** `natasha`
* **Source Path:** `/tmp/index.html` (on Jump Host)
* **Destination Path:** `/usr/src/kodekloudrepos/ecommerce/` (on Storage Server)
* **Git Repository:** `/usr/src/kodekloudrepos/ecommerce` (cloned from `/opt/ecommerce.git`)

---

## Execution Steps

### 1. Multi-stage File Transfer
Due to permission restrictions on the target directory, a direct `scp` to the destination was not possible. The file was first transferred to a neutral directory (`/tmp/`) and then moved using elevated privileges.

**From Jump Host:**
```bash
scp /tmp/index.html natasha@ststor01:/tmp/
```

**From Storage Server:**
```bash
ssh natasha@ststor01
sudo cp /tmp/index.html /usr/src/kodekloudrepos/ecommerce/
```

### 2. Handling Git Ownership and Security Constraints
The repository was owned by the `root` user, which triggered Git's modern security protections (`dubious ownership`). To proceed without changing directory permissions, the following configurations were applied to the `root` user's profile:

```bash
# Set Git identity for the root user
sudo git config --global user.email "natasha@nautilus.com"
sudo git config --global user.name "Natasha"

# Add directories to the safe list to bypass ownership checks
sudo git config --global --add safe.directory /usr/src/kodekloudrepos/ecommerce
sudo git config --global --add safe.directory /opt/ecommerce.git
```

### 3. Git Workflow (Add, Commit, Push)
With the file in place and security exceptions configured, the changes were committed and pushed to the master branch using `sudo` to maintain compatibility with the existing directory ownership.

```bash
cd /usr/src/kodekloudrepos/ecommerce
sudo git add index.html
sudo git commit -m "Add sample index.html"
sudo git push origin master
```

---

## Troubleshooting Summary
* **Permission Denied (SCP):** Solved by using `/tmp` as an intermediate landing zone.
* **Dubious Ownership:** Resolved by adding the paths to `safe.directory` in the global git config.
* **Permission Denied (index.lock):** Resolved by executing Git commands with `sudo` since the `.git` metadata directory was root-owned.

## Verification
Final verification confirmed that the changes were successfully pushed to the remote repository:
`Everything up-to-date` (after a successful push) or the standard Git push success message.