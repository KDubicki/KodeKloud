# !/bin/bash

# Connect to App Server 3
ssh banner@stapp03

# Install Tomcat
sudo yum install -y tomcat

# Change the Port to 6400
sudo sed -i 's/port="8080"/port="6400"/g' /etc/tomcat/server.xml

# Deploy the WAR File
exit
sudo scp /tmp/ROOT.war banner@stapp03:/tmp/
# Log back in
ssh banner@stapp03

# Remove any existing default ROOT folder/war
sudo rm -rf /var/lib/tomcat/webapps/ROOT*

# Move the new war file
sudo mv /tmp/ROOT.war /var/lib/tomcat/webapps/

# Start and Enable Tomcat
sudo systemctl start tomcat
sudo systemctl enable tomcat

# Verification
curl http://stapp03:6400