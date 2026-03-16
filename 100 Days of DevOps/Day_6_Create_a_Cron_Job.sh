# !/bin/bash

# Install and Start Cronie
sudo yum install -y cronie
sudo systemctl start crond
sudo systemctl enable crond

# Add the Cron Job for Root
echo "*/5 * * * * echo hello > /tmp/cron_text" | sudo crontab -