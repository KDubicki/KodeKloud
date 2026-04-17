# Nautilus DevOps Task: Day 80 - Jenkins Chained Builds

## Objective
The DevOps team requires a multi-job (chained) pipeline where the deployment of a web application and the restarting of web services are decoupled. We need to create an upstream job that deploys code from a Gitea repository to the application server (`App Server 1`), and a downstream job that restarts the Apache service (`httpd`) *only* if the deployment succeeds (build is stable).

## Environment Details
* **Jenkins UI:** `admin` / `Adm!n321`
* **Gitea UI:** `sarah` / `Sarah_pass123`
* **App Server 1 (stapp01):** User `sarah`, Password `Sarah_pass123`
* **Gitea Repository:** `web` repository on the `master` branch.
* **Target Environment:** Apache (`httpd`) document root `/var/www/html`

---

## Execution Steps

### 1. Environment & Node Setup
To ensure Jenkins can communicate with the agent and execute the deployment:
1. **Plugins:** Verified that the **SSH Build Agents** and **Git** plugins were installed on the Jenkins Master.
2. **Java Compatibility:** Updated Java on the target application server (`stapp01`) to support Jenkins Remoting:
   ```bash
   ssh tony@stapp01 "echo 'Ir0nM@n' | sudo -S yum install -y java-17-openjdk"
   ```
3. **Jenkins Credentials:** Added a global credential (`Username with password`) using `sarah` and `Sarah_pass123` (ID: `sarah-cred`).
4. **Agent Setup:** Configured `App Server 1` as a Permanent Agent running via SSH, mapped to the label `stapp01`.

### 2. Configure Upstream Job (`datacenter-app-deployment`)
Created the primary Freestyle project to handle code deployment.
1. **General:** Restricted execution to the `stapp01` node.
2. **Source Code Management:** Configured Git with the Gitea repository URL (`web`), using the `sarah-cred` credentials and targeting the `*/master` branch.
3. **Build Steps (Execute Shell):** Added a shell command to copy the cloned files to the Apache document root securely using `sudo`.
   ```bash
   echo 'Sarah_pass123' | sudo -S cp -r * /var/www/html/
   ```
*(Note: Post-build actions were intentionally left blank here to utilize a reverse-triggering mechanism in the downstream job for better stability).*

### 3. Configure Downstream Job (`manage-services`)
Created a secondary Freestyle project to handle the service restart.
1. **General:** Restricted execution to the `stapp01` node.
2. **Build Triggers:** Checked **Build after other projects are built**.
   * **Projects to watch:** `datacenter-app-deployment`
   * **Condition:** Trigger only if build is stable.
3. **Build Steps (Execute Shell):** Added a shell command to restart the Apache service securely.
   ```bash
   echo 'Sarah_pass123' | sudo -S systemctl restart httpd
   ```

### 4. Verification & Testing
1. Triggered a manual build of the `datacenter-app-deployment` job (Upstream).
2. Verified through the Jenkins console output that the files were successfully copied to `/var/www/html/` (Status: `SUCCESS`).
3. Monitored the Jenkins dashboard and confirmed that the downstream job (`manage-services`) automatically triggered and executed successfully immediately after the upstream job completed.
4. Accessed the Load Balancer `App` URL to ensure the updated website was functioning correctly and serving from the root domain.

---

## Technical Notes & Troubleshooting
* **Reverse Triggering (Listening Downstream):** Initially, configuring the upstream job to push a trigger via "Post-build Actions" can sometimes fail due to plugin visibility or queue delays. A robust DevOps workaround used in this lab was configuring the downstream job to "listen" for the upstream job's completion. This ensures the chained build triggers reliably without strict upstream dependencies.