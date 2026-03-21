# !/bin/bash

# Copy the website files from the jump host to App Server 3's temporary folder
scp -r /home/thor/official /home/thor/apps banner@stapp03:/tmp/

# Log into App Server 3
ssh banner@stapp03
sudo su -

# Install Apache
yum install -y httpd

# Change the listening port to 6400
sed -i 's/^Listen .*/Listen 6400/g' /etc/httpd/conf/httpd.conf

# Move the website files
cp -r /tmp/official /var/www/html/
cp -r /tmp/apps /var/www/html/

# Start and enable Apache
systemctl start httpd
systemctl enable httpd


# Test to make sure it works
curl http://localhost:6400/official/
curl http://localhost:6400/apps/