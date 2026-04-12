# Nautilus DevOps Task: Day 77 - Jenkins Deploy Pipeline

## Objective
Automate the deployment of a new static website from a Gitea repository to the application server (`App Server 1`). The task involved creating a Jenkins Pipeline that pulls the latest code from the `web_app` repository (maintained by developer `sarah`) and deploys it directly to the Apache document root (`/var/www/html`).

## Credentials & Environment
* **Jenkins UI:** `admin` / `Adm!n321`
* **Gitea UI:** `sarah` / `Sarah_pass123`
* **App Server 1 (stapp01):** User `sarah`, Password `Sarah_pass123`
* **Gitea Repository URL:** `https://3000-port-nlg7q5krmqhjgrfo.labs.kodekloud.com/sarah/web_app.git`

---

## Execution Steps

### 1. Plugin Installation
In this environment, the following plugins were required and installed:
1. **SSH Build Agents** – To connect to the application server as a build node.
2. **Pipeline** – To enable the creation of Pipeline-type jobs.
3. **Git** – To handle the `git` command within the Pipeline steps.

*Note: Jenkins was restarted after each installation to activate the plugins.*

### 2. Credential Configuration
A new credential was added in **Manage Jenkins -> Credentials**:
* **Kind:** Username with password
* **Username:** `sarah`
* **Password:** `Sarah_pass123`
* **ID:** `sarah-cred`

### 3. Slave Node (Agent) Configuration
A new node named `App Server 1` was added:
* **Remote root directory:** `/home/sarah/jenkins_agent`
* **Labels:** `stapp01`
* **Launch method:** Launch agents via SSH
* **Host:** `stapp01`
* **Credentials:** `sarah-cred`
* **Host Key Verification Strategy:** Non-verifying Verification Strategy

#### Troubleshooting: Java Version Mismatch
The agent failed to launch initially because the Jenkins Controller required Java 17, while the App Server had Java 11. The issue was resolved by updating Java on `stapp01` via the terminal:
```bash
ssh tony@stapp01 "echo 'Ir0nM@n' | sudo -S yum install -y java-17-openjdk"
```

### 4. Pipeline Creation and Configuration
A **Pipeline** job named `devops-webapp-job` was created. The following declarative script was used:

```groovy
pipeline {
    agent { 
        label 'stapp01' 
    }
    stages {
        stage('Deploy') {
            steps {
                // 1. Pull the latest code from the Gitea repository
                git credentialsId: 'sarah-cred', 
                    url: '[https://3000-port-nlg7q5krmqhjgrfo.labs.kodekloud.com/sarah/web_app.git](https://3000-port-nlg7q5krmqhjgrfo.labs.kodekloud.com/sarah/web_app.git)', 
                    branch: 'master'
                
                // 2. Deploy files to the Apache document root using sudo with password echo
                sh "echo 'Sarah_pass123' | sudo -S cp -r * /var/www/html/"
            }
        }
    }
}
```

### 5. Verification
1. Triggered the build using the **Build Now** button.
2. Verified the **Console Output** for a `SUCCESS` status.
3. Accessed the Load Balancer URL via the **App** button and confirmed the static website was loading correctly from the root domain.