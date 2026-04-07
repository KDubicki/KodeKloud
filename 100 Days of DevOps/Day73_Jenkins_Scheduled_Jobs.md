# Nautilus DevOps Task: Day 73 - Jenkins Scheduled Jobs

## Objective
The Nautilus DevOps team needs to collect Apache server logs (`access_log` and `error_log`) from App Server 2 (`stapp02`) on a regular schedule to assist with centralized logging and troubleshooting. The task involves creating a Jenkins job named `copy-logs` that executes every 2 minutes to transfer these logs to the Storage Server (`ststor01`) at `/usr/src/dba`.

## Prerequisites
* Jenkins Web UI access: `admin` / `Adm!n321`
* App Server 2 (`stapp02`) credentials: `steve` / `Am3ric@`
* Storage Server (`ststor01`) credentials: `natasha` / `Bl@kW`

---

## Execution Steps

### 1. Configure SSH Authentication
To allow Jenkins to seamlessly transfer files between servers without getting stuck on interactive password prompts, SSH key authentication must be established.

1. Access the Jenkins server terminal:
   ```bash
   ssh jenkins@jenkins
   ```
2. Generate an SSH keypair for the Jenkins user (press Enter to accept the default path and no passphrase):
   ```bash
   ssh-keygen -t rsa -b 4096
   ```
3. Distribute the public key to both target servers:
   ```bash
   ssh-copy-id steve@stapp02
   # Accept host key (yes) and enter password: Am3ric@
   
   ssh-copy-id natasha@ststor01
   # Accept host key (yes) and enter password: Bl@kW
   ```
4. Exit the Jenkins server terminal.

### 2. Create the Scheduled Jenkins Job
1. Log into the Jenkins UI and click **New Item**.
2. Name the job `copy-logs`, select **Freestyle project**, and click **OK**.
3. Under the **Build Triggers** section, check the box for **Build periodically**.
4. Enter the cron expression for a 2-minute interval:
   ```text
   */2 * * * *
   ```

### 3. Configure the Build Steps
1. Scroll down to **Build Steps** and click **Add build step** -> **Execute shell**.
2. Insert the following bash script. 
   *(Note: The script safely reads protected logs using `sudo`, transfers them to a temporary directory, ensures the target directory exists using `mkdir -p`, and finally moves them to the restricted destination.)*

   ```bash
   #!/bin/bash
   
   # 1. Read protected Apache logs from App Server 2 and pipe them to local workspace files
   ssh -o StrictHostKeyChecking=no steve@stapp02 "echo 'Am3ric@' | sudo -S cat /var/log/httpd/access_log" > access_log
   ssh -o StrictHostKeyChecking=no steve@stapp02 "echo 'Am3ric@' | sudo -S cat /var/log/httpd/error_log" > error_log
   
   # 2. Transfer the extracted logs to a temporary directory on the Storage Server
   scp -o StrictHostKeyChecking=no access_log error_log natasha@ststor01:/tmp/
   
   # 3. Create the target directory (if it doesn't exist) and move the logs using sudo
   ssh -o StrictHostKeyChecking=no natasha@ststor01 "echo 'Bl@kW' | sudo -S mkdir -p /usr/src/dba/"
   ssh -o StrictHostKeyChecking=no natasha@ststor01 "echo 'Bl@kW' | sudo -S cp /tmp/access_log /usr/src/dba/"
   ssh -o StrictHostKeyChecking=no natasha@ststor01 "echo 'Bl@kW' | sudo -S cp /tmp/error_log /usr/src/dba/"
   ```
3. Click **Save**.

### 4. Verification
1. Click **Build Now** to execute the job manually for immediate verification.
2. Review the **Console Output** to ensure a successful transfer (`SUCCESS`).
3. Wait at least 2 minutes to verify that the cron schedule triggers a subsequent build automatically without errors.