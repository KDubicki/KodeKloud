# Nautilus DevOps Task: Day 74 - Jenkins Database Backup Job

## Objective
Automate the backup of the `kodekloud_db01` database located on App Server 1 (`stapp01`). The Jenkins job must take a daily dump of the database, name it dynamically with the current date, and securely transfer it to the Storage Server (`ststor01`) on a periodic schedule.

## Prerequisites
* Jenkins Web UI access: `admin` / `Adm!n321`
* App Server 1 (`stapp01`) credentials: `tony` / `Ir0nM@n`
* Storage Server (`ststor01`) credentials: `natasha` / `Bl@kW`
* Database user: `kodekloud_roy`
* Database pass: `asdfgdsd`

---

## Execution Steps

### 1. Configure SSH Authentication
To allow Jenkins to seamlessly transfer files and execute remote commands without interactive password prompts, SSH key authentication is required.

1. Access the Jenkins server terminal:
   ```bash
   ssh jenkins@jenkins
   ```
2. Generate an SSH keypair for the Jenkins user:
   ```bash
   ssh-keygen -t rsa -b 4096
   # Press Enter to accept defaults and create a key with no passphrase
   ```
3. Distribute the public key to both target servers:
   ```bash
   # Copy to App Server 1
   ssh-copy-id tony@stapp01
   # Password: Ir0nM@n
   
   # Copy to Storage Server
   ssh-copy-id natasha@ststor01
   # Password: Bl@kW
   ```
4. Exit the Jenkins server terminal.

### 2. Create the Jenkins Job
1. Log into the Jenkins UI and click **New Item**.
2. Name the job `database-backup`, select **Freestyle project**, and click **OK**.
3. Under the **Build Triggers** section, check **Build periodically**.
4. Enter the required cron expression to run the job every 10 minutes:
   ```text
   */10 * * * *
   ```

### 3. Configure the Build Steps
1. Scroll down to **Build Steps** and click **Add build step** -> **Execute shell**.
2. Insert the following bash script to handle the dump and transfer:

   ```bash
   #!/bin/bash
   
   # Define the dynamic filename using the current date
   DUMP_FILE="db_$(date +%F).sql"
   
   # 1. Execute mysqldump remotely on App Server 1 and save it to /tmp
   ssh -o StrictHostKeyChecking=no tony@stapp01 "mysqldump -u kodekloud_roy -pasdfgdsd kodekloud_db01 > /tmp/${DUMP_FILE}"
   
   # 2. Securely copy the dump from App Server 1 to the local Jenkins workspace
   scp -o StrictHostKeyChecking=no tony@stapp01:/tmp/${DUMP_FILE} .
   
   # 3. Ensure the target directory exists on the Storage Server
   ssh -o StrictHostKeyChecking=no natasha@ststor01 "mkdir -p /home/natasha/db_backups"
   
   # 4. Transfer the dump to the final destination on the Storage Server
   scp -o StrictHostKeyChecking=no ${DUMP_FILE} natasha@ststor01:/home/natasha/db_backups/
   ```
3. Click **Save**.

### 4. Verification
1. Click **Build Now** to execute the job manually.
2. Review the **Console Output** to ensure the database was dumped and transferred successfully (`SUCCESS`).
3. The cron schedule will automatically trigger subsequent builds every 10 minutes.