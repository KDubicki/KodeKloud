# !/bin/bash

# Storage Server
ssh banner@stapp03
sudo su -

# Install Nginx and PHP-FPM 8.3
dnf module enable php:8.3 -y
yum install -y nginx php-fpm

# Configure PHP-FPM
# =============================================================================
# Create the parent directory for the socket
mkdir -p /var/run/php-fpm
chown nginx:nginx /var/run/php-fpm

# Update the PHP-FPM configuration
sed -i 's|^listen =.*|listen = /var/run/php-fpm/default.sock|' /etc/php-fpm.d/www.conf
sed -i 's|^;listen.owner =.*|listen.owner = nginx|' /etc/php-fpm.d/www.conf
sed -i 's|^;listen.group =.*|listen.group = nginx|' /etc/php-fpm.d/www.conf
sed -i 's|^;listen.mode =.*|listen.mode = 0660|' /etc/php-fpm.d/www.conf
sed -i 's|^user =.*|user = nginx|' /etc/php-fpm.d/www.conf
sed -i 's|^group =.*|group = nginx|' /etc/php-fpm.d/www.conf
# =============================================================================

# Configure Nginx
cat << 'EOF' > /etc/nginx/conf.d/php-app.conf
server {
    listen 8099;
    server_name _;
    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php-fpm/default.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

# Start Services and Fix Permissions
chown -R nginx:nginx /var/www/html
systemctl start php-fpm nginx
systemctl enable php-fpm nginx
systemctl status php-fpm
systemctl status nginx

# Test
curl http://localhost:8099/index.php
curl http://stapp03:8099/index.php