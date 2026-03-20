# !/bin/bash

# Prepare the App Servers
ssh tony@stapp01
sudo su -
grep "^Listen" /etc/httpd/conf/httpd.conf
systemctl start httpd
systemctl enable httpd

# Configure the Load Balancer
ssh loki@stlb01
sudo su -
yum install -y epel-release nginx
vi /etc/nginx/nginx.conf

# Add the following upstream block before the server block
upstream backend {
    server stapp01:8089;
    server stapp02:8089;
    server stapp03:8089;
}

# Modify the server block to proxy requests to the backend
location / {
    proxy_pass http://backend;
}

# Test and Start Nginx
nginx -t
systemctl start nginx
systemctl enable nginx

# Final Test
curl http://stlb01:80