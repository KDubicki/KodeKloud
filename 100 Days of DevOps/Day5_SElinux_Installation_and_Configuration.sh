# !/bin/bash

# SElinux Installation and Configuration
sudo yum install -y selinux-policy selinux-policy-targeted policycoreutils
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config