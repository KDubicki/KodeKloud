# Nautilus DevOps Task: Day 81 - Jenkins Multistage Pipeline

## Objective
The development team required a Jenkins Declarative Pipeline to automate the deployment and testing of a static website on `App Server 1`. The pipeline needed to consist of two specific stages: `Deploy` (to copy files to the Apache document root) and `Test` (to verify the application's availability via the Load Balancer URL). 

## Environment Details
* **Jenkins UI:** `admin` / `Adm!n321`
* **Gitea UI:** `sarah` / `Sarah_pass123`
* **App Server 1 (stapp01):** User `sarah`, Password `Sarah_pass123`
* **Target Environment:** Apache (`httpd`) document root at `/var/www/html`
* **LBR Test URL:** `http://stlb01:8091`

---

## Execution Steps

### 1. Source Code Update (Git Workflow)
In this specific scenario, the repository was already cloned directly into the `/var/www/html` directory rather than the user's home directory. We had to take ownership of the directory, update the index file, and push the changes to Gitea:

```bash
# SSH into the App Server
ssh sarah@stapp01

# Navigate to the document root where the repo is cloned
cd /var/www/html

# Ensure the 'sarah' user has the correct permissions to modify and commit files
echo 'Sarah_pass123' | sudo -S chown -R sarah:sarah /var/www/html

# Update the index file as per requirements
echo "Welcome to xFusionCorp Industries" > index.html

# Configure Git
git config --global user.email "sarah@xfusioncorp.com"
git config --global user.name "Sarah"

# Commit and push changes to the master branch
git add index.html
git commit -m "Update index page for multistage pipeline"
git push origin master
```

### 2. Jenkins Environment & Node Setup
To ensure Jenkins could execute the pipeline on the target server:
1. **Plugins:** Verified and installed **SSH Build Agents**, **Pipeline**, and **Git** plugins on the Jenkins Master.
2. **Java Compatibility:** Updated Java to version 17 on `App Server 1` to allow Jenkins Remoting:
   ```bash
   ssh tony@stapp01 "echo 'Ir0nM@n' | sudo -S yum install -y java-17-openjdk"
   ```
3. **Credentials:** Added a Global Credential (`Username with password`) using `sarah` and `Sarah_pass123` (ID: `sarah-cred`).
4. **Agent Setup:** Added `App Server 1` as a Permanent Agent:
   * **Remote root directory:** `/home/sarah/jenkins_agent`
   * **Labels:** `stapp01`
   * **Launch method:** SSH using `sarah-cred` with `Non-verifying Verification Strategy`.

### 3. Pipeline Configuration (`deploy-job`)
Created a new Pipeline job named `deploy-job`. The script executes on the `stapp01` node and includes the two mandatory stages. 
*(Note: A direct lab-provided Gitea URL was used to bypass internal DNS resolution issues).*

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
                    url: '[https://3000-port-bm2576jjw5kmakjx.labs.kodekloud.com/sarah/web.git](https://3000-port-bm2576jjw5kmakjx.labs.kodekloud.com/sarah/web.git)', 
                    branch: 'master'
                
                // 2. Deploy the code to the Apache document root using sudo
                sh "echo 'Sarah_pass123' | sudo -S cp -r * /var/www/html/"
            }
        }
        stage('Test') {
            steps {
                // 3. Verify application availability via the Load Balancer
                // The -f (--fail) flag ensures curl returns an error code on HTTP failures (e.g., 404, 500)
                sh "curl -f http://stlb01:8091"
            }
        }
    }
}
```

### 4. Verification
1. Triggered the pipeline manually via **Build Now**.
2. Confirmed in the Jenkins UI that both the `Deploy` and `Test` stages executed successfully (marked with green checkmarks).
3. Accessed the live Load Balancer URL (`http://stlb01:8091`) and verified that the page displayed exactly: `Welcome to xFusionCorp Industries`.