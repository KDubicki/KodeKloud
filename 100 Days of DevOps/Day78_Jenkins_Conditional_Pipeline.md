# Nautilus DevOps Task: Day 78 - Jenkins Conditional Pipeline

## Objective
The goal of this task was to create a parameterized Jenkins Pipeline to deploy a static website to `App Server 1`. The pipeline was required to accept a string parameter named `BRANCH` and conditionally deploy either the `master` or `feature` branch from the Gitea repository. The deployment process must occur within a single stage named `Deploy`.

## Environment Details
* **Jenkins UI:** `admin` / `Adm!n321`
* **Gitea UI:** `sarah` / `Sarah_pass123`
* **App Server 1 (stapp01):** User `sarah`, Password `Sarah_pass123`
* **Gitea Repository URL:** `https://3000-port-eqxowc4nkszd2the.labs.kodekloud.com/sarah/web_app.git`

---

## Execution Steps

### 1. Initial Setup (Plugins & Node)
1. **Plugins:** Installed **SSH Build Agents**, **Pipeline**, and **Git** plugins on the Jenkins Master.
2. **Java Update:** Since the Jenkins agent requires Java 17 to communicate with the Master, Java was updated on `stapp01` via the terminal:
   ```bash
   ssh tony@stapp01 "echo 'Ir0nM@n' | sudo -S yum install -y java-17-openjdk"
   ```
3. **Node Configuration:** Added `App Server 1` as a permanent agent:
   * **Remote root directory:** `/home/sarah/jenkins_agent`
   * **Labels:** `stapp01`
   * **Launch method:** SSH, using `sarah-cred` credentials and `Non-verifying Verification Strategy`.

### 2. Pipeline Configuration
A new Pipeline job named `devops-webapp-job` was created with the following features:
1. **Parameters:** Enabled **This project is parameterized** and added a **String Parameter**:
   * **Name:** `BRANCH`
   * **Default Value:** `master`
2. **Pipeline Script:** Used a Declarative Pipeline with a `script` block to handle conditional branching logic.

### 3. Final Pipeline Code
The following script handles the deployment. It checks the value of the `BRANCH` parameter and pulls the corresponding branch from Gitea before moving files to the web directory.

```groovy
pipeline {
    agent { 
        label 'stapp01' 
    }
    stages {
        stage('Deploy') {
            steps {
                script {
                    // Conditional branching logic using the BRANCH parameter
                    if (params.BRANCH == 'master') {
                        git credentialsId: 'sarah-cred', 
                            url: '[https://3000-port-eqxowc4nkszd2the.labs.kodekloud.com/sarah/web_app.git](https://3000-port-eqxowc4nkszd2the.labs.kodekloud.com/sarah/web_app.git)', 
                            branch: 'master'
                    } else if (params.BRANCH == 'feature') {
                        git credentialsId: 'sarah-cred', 
                            url: '[https://3000-port-eqxowc4nkszd2the.labs.kodekloud.com/sarah/web_app.git](https://3000-port-eqxowc4nkszd2the.labs.kodekloud.com/sarah/web_app.git)', 
                            branch: 'feature'
                    } else {
                        error("Invalid branch provided! Use 'master' or 'feature'.")
                    }
                }
                
                // Deploying files to Apache doc root with non-interactive sudo
                sh "echo 'Sarah_pass123' | sudo -S cp -r * /var/www/html/"
            }
        }
    }
}
```

---

## Troubleshooting & Key Fixes

### DNS/Host Resolution Issue
* **Problem:** The pipeline failed with `Could not resolve host: git.stratos.xfusioncorp.com`.
* **Fix:** Replaced the internal hostname with the direct lab-provided URL (`https://3000-port-...`) in the `git` step to ensure connectivity from the agent to the Gitea server.

### Non-interactive Sudo Authentication
* **Problem:** The `sudo cp` command failed because `sudo` required a password but didn't have a terminal to read it from.
* **Fix:** Used the `echo 'password' | sudo -S` pattern to pass the password securely via standard input.

---

## Verification
1. Executed **Build with Parameters** with `BRANCH=master`. Output: `SUCCESS`.
2. Executed **Build with Parameters** with `BRANCH=feature`. Output: `SUCCESS`.
3. Verified the website content by accessing the Load Balancer URL via the **App** button.