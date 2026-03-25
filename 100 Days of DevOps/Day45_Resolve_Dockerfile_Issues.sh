# !/bin/bash

# =================================================================
# Log in
# =================================================================
ssh tony@stapp01
sudo su -

# =================================================================
# Investigate the Broken File
# =================================================================
cd /opt/docker
# Show me the files in the directory
ls -l
# Show me the contents of the broken Dockerfile
cat Dockerfile

"""
Mistake 1: Absolute Paths in COPY (COPY /server.crt)
Mistake 2: Forgetting the HTML! (add COPY html/index.html)
"""

# =================================================================
# Overwrite with the Dockerfile
# =================================================================
cat << 'EOF' > Dockerfile
FROM httpd:2.4.43

RUN sed -i "s/Listen 80/Listen 8080/g" /usr/local/apache2/conf/httpd.conf
RUN sed -i '/LoadModule\ ssl_module modules\/mod_ssl.so/s/^#//g' conf/httpd.conf
RUN sed -i '/LoadModule\ socache_shmcb_module modules\/mod_socache_shmcb.so/s/^#//g' conf/httpd.conf
RUN sed -i '/Include\ conf\/extra\/httpd-ssl.conf/s/^#//g' conf/httpd.conf

COPY certs/server.crt /usr/local/apache2/conf/server.crt
COPY certs/server.key /usr/local/apache2/conf/server.key
COPY html/index.html /usr/local/apache2/htdocs/
EOF

# =================================================================
# Test the Build
# =================================================================
docker build -t test-image .