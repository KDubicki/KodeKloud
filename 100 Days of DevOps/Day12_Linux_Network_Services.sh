# !/bin/bash

# Log in and get root access
ssh tony@stapp01
sudo su -

# Fix the Apache Configuration
sed -i 's/^Listen .*/Listen 5001/g' /etc/httpd/conf/httpd.conf

# Clear Port 5001 (If blocked)
ss -tulpn | grep 5001
# If you find any process, kill it (Replace <PID> with actual PID)
kill -9 <PID>

# Start Apache
systemctl start httpd
systemctl enable httpd
systemctl status httpd

# Test Locally & Fix Firewall
curl http://localhost:5001
iptables -I INPUT -p tcp --dport 5001 -j ACCEPT


# Return to jump Host
curl http://stapp01:5001