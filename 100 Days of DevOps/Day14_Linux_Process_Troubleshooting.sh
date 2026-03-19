# !/bin/bash

# App Server 1
ssh tony@stapp01
sudo su -
yum install -y httpd
sed -i 's/^Listen .*/Listen 6000/g' /etc/httpd/conf/httpd.conf
systemctl start httpd
systemctl enable httpd
systemctl status httpd

# App Server 2
ssh natasha@stapp02
sudo su -
yum install -y httpd
sed -i 's/^Listen .*/Listen 6000/g' /etc/httpd/conf/httpd.conf
systemctl start httpd
systemctl enable httpd
systemctl status httpd

# App Server 3
ssh banner@stapp03
sudo su -
yum install -y httpd
sed -i 's/^Listen .*/Listen 6000/g' /etc/httpd/conf/httpd.conf
systemctl start httpd
systemctl enable httpd
systemctl status httpd