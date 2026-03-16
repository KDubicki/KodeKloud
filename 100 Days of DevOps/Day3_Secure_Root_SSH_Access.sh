# !/bin/bash

# Secure Root SSH Access
ssh tony@stapp01
ssh steve@stapp02
ssh banner@stapp03

# Disable root login via SSH
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd