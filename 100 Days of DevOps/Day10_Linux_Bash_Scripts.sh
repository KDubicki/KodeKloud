# !/bin/bash

sudo yum install -y zip
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
ssh-copy-id natasha@ststor01


vi /scripts/beta_backup.sh

# =============================================================================

#!/bin/bash

# --- Configuration ---
SOURCE_DIR="/var/www/html/beta"
BACKUP_NAME="xfusioncorp_beta.zip"
LOCAL_BACKUP_DIR="/backup"
REMOTE_SERVER="ststor01"         # Nautilus Storage Server hostname/IP
REMOTE_BACKUP_DIR="/backup"
REMOTE_USER="steve"              # Respective server user

# --- a & b. Create zip archive and save locally ---
# We use -r for recursive and -q for quiet mode
zip -rq "${LOCAL_BACKUP_DIR}/${BACKUP_NAME}" "${SOURCE_DIR}"

# --- c. Copy the archive to Nautilus Storage Server ---
# scp uses the SSH keys we set up in Step 2
scp "${LOCAL_BACKUP_DIR}/${BACKUP_NAME}" "${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_BACKUP_DIR}/"

echo "Backup completed and transferred successfully."

# =============================================================================

sudo mkdir -p /scripts
sudo chown steve:steve /scripts
chmod +rx /scripts/beta_backup.sh