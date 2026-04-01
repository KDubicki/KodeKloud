# !/bin/bash

# =================================================================
# Connect and Install
# =================================================================
ssh root@jenkins

# =================================================================
# Update packages and install Java 17
# =================================================================
apt update
apt install openjdk-17-jre -y

# =================================================================
# Install Jenkins
# =================================================================
apt install jenkins -y

# =================================================================
# Set Java 17 as the default
# =================================================================
update-alternatives --config java
# press Enter

# =================================================================
# Start the Jenkins service
# =================================================================
service jenkins start
service jenkins status

# =================================================================
# Retrieve the Initial Admin Password
# =================================================================
cat /var/lib/jenkins/secrets/initialAdminPassword

# =================================================================
# UI Setup (Browser)
# =================================================================
"""
1. Click the Jenkins button on the top bar of your lab environment interface to open the Jenkins UI.
2. Unlock Jenkins: Paste the initial admin password you copied from the terminal and click Continue.
3. Customize Jenkins: Click Install suggested plugins and wait for the installation to finish.
4. Create First Admin User: Fill in the exact details required by your task:
    - Username: theadmin
    - Password: Adm!n321
    - Confirm Password: Adm!n321
    - Full Name: Yousuf
    - E-mail address: yousuf@jenkins.stratos.xfusioncorp.com
5.Click Save and Continue.
6. On the Instance Configuration page, leave the default URL and click Save and Finish.
7. Click Start using Jenkins.
"""