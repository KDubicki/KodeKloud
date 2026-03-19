# !/bin/bash

# App Server 1
ssh tony@stapp01
sudo su -
yum install -y iptables iptables-services
iptables -I INPUT 1 -p tcp -s stlb01 --dport 3003 -j ACCEPT
iptables -I INPUT 2 -p tcp --dport 3003 -j DROP
iptables-save > /etc/sysconfig/iptables
systemctl start iptables
systemctl enable iptables

# App Server 2
ssh natasha@stapp02
sudo su -
yum install -y iptables iptables-services
iptables -I INPUT 1 -p tcp -s stlb01 --dport 3003 -j ACCEPT
iptables -I INPUT 2 -p tcp --dport 3003 -j DROP
iptables-save > /etc/sysconfig/iptables
systemctl start iptables
systemctl enable iptables

# App Server 3
ssh banner@stapp03
sudo su -
yum install -y iptables iptables-services
iptables -I INPUT 1 -p tcp -s stlb01 --dport 3003 -j ACCEPT
iptables -I INPUT 2 -p tcp --dport 3003 -j DROP
iptables-save > /etc/sysconfig/iptables
systemctl start iptables
systemctl enable iptables