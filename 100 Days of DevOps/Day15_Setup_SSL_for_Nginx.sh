# !/bin/bash

ssh banner@stapp03
sudo su -

# Install Nginx
yum install -y epel-release
yum install -y nginx

# Move the SSL Certificates
mkdir -p /etc/nginx/ssl
mv /tmp/nautilus.crt /etc/nginx/ssl/
mv /tmp/nautilus.key /etc/nginx/ssl/

# Configure Nginx for SSL
cat <<EOF > /etc/nginx/conf.d/ssl.conf
server {
    listen 443 ssl;
    server_name stapp03;

    ssl_certificate /etc/nginx/ssl/nautilus.crt;
    ssl_certificate_key /etc/nginx/ssl/nautilus.key;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOF

# Create the index.html file
echo "Welcome!" > /usr/share/nginx/html/index.html

# Start and Enable Nginx
systemctl start nginx
systemctl enable nginx

systemctl status nginx

# Test from the Jump Host
curl -Ik https://stapp03/