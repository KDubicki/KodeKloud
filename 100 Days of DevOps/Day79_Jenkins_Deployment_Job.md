# Nautilus DevOps Task: Day 79 - Jenkins Deployment Job

## Objective
The Nautilus development team requires an automated deployment pipeline for a web application hosted in the Stratos Datacenter. The goal is to configure a Jenkins job (`xfusion-app-deployment`) that automatically builds and deploys the latest code to `App Server 1` (`/var/www/html`) whenever a developer pushes changes to the `master` branch of the `web` repository.

## Environment Details
* **Jenkins UI:** `admin` / `Adm!n321`
* **Gitea UI:** `sarah` / `Sarah_pass123`
* **App Server 1 (stapp01):** User `sarah`, Password `Sarah_pass123`
* **Gitea Repository:** `web` repository owned by `sarah`
* **Target Environment:** Apache (`httpd`) document root at `/var/www/html`

---

## Execution Steps

### 1. Prerequisites & Node Setup
To ensure Jenkins can communicate with the agent and clone the Git repository, the following initial steps were performed:

1. **Jenkins Plugins:** Installed the **SSH Build Agents** and **Git** plugins on the Jenkins Master.
2. **Java Compatibility:** Updated Java to version 17 on `App Server 1` to support Jenkins Remoting:
   ```bash
   ssh tony@stapp01 "echo 'Ir0nM@n' | sudo -S yum install -y java-17-openjdk"
   ```
3. **Jenkins Credentials:** Added a Global Credential (`Username with password`) in Jenkins:
   * **Username:** `sarah`
   * **Password:** `Sarah_pass123`
   * **ID:** `sarah-cred`
4. **Agent Configuration:** Added `App Server 1` as a Permanent Agent:
   * **Remote root directory:** `/home/sarah/jenkins_agent`
   * **Labels:** `stapp01`
   * **Launch method:** Launch agents via SSH (Host: `stapp01`, Credentials: `sarah-cred`, Strategy: `Non-verifying Verification Strategy`).

### 2. Jenkins Job Configuration
Created a new **Freestyle project** named `xfusion-app-deployment` configured as follows:

1. **General:** Checked **Restrict where this project can be run** and set the label expression to `stapp01`.
2. **Source Code Management:** * Selected **Git**.
   * Repository URL: *[Direct Gitea HTTP URL for the `web` repository]*
   * Credentials: `sarah-cred`
   * Branch Specifier: `*/master`
3. **Build Triggers:**
   * Enabled **Poll SCM** and set the schedule to `* * * * *`. 
   * *Note: This forces Jenkins to poll the repository every minute. In this specific lab environment, this is the most reliable way to simulate a webhook trigger without dealing with internal DNS/Docker networking limitations.*
4. **Build Steps (Execute Shell):**
   * Added the following shell script to start Apache, change ownership of the web directory to `sarah` (as required), and deploy the code.
   ```bash
   # 1. Ensure the Apache web server is running
   echo 'Sarah_pass123' | sudo -S systemctl start httpd
   
   # 2. Change ownership of the document root to user 'sarah'
   echo 'Sarah_pass123' | sudo -S chown -R sarah:sarah /var/www/html
   
   # 3. Copy the cloned repository contents to the document root
   cp -r * /var/www/html/
   ```

### 3. Developer Workflow (Triggering the CI/CD Pipeline)
To test the automation, the local code on the application server was modified and pushed to the remote repository.

```bash
# Log into the application server as the developer
ssh sarah@stapp01

# Navigate to the pre-cloned repository
cd /home/sarah/web

# Update the content of the index page per requirements
echo "Welcome to the xFusionCorp Industries" > index.html

# Configure git credentials (first-time setup)
git config --global user.email "sarah@xfusioncorp.com"
git config --global user.name "Sarah"

# Commit and push the changes to Gitea
git add .
git commit -m "Update index page for auto-deployment"
git push origin master
```

### 4. Verification
1. **Jenkins Dashboard:** Verified that within 60 seconds of the `git push`, the `xfusion-app-deployment` job automatically triggered and completed with a `SUCCESS` status.
2. **Application Verification:** Clicked the Load Balancer `App` button and confirmed that the URL successfully loaded the updated text: `"Welcome to the xFusionCorp Industries"`, without navigating to any sub-directories.