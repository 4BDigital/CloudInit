#!/bin/bash
apt-get update
apt-get upgrade -y
sudo apt --purge autoremove -y 
apt-get install cloud-init wget -y
hostname localhost
echo "localhost" > /etc/hostname
userdel -r ubuntu
echo "datasource:
  CloudStack: {}
  None: {}
datasource_list:
  - CloudStack" > /etc/cloud/cloud.cfg.d/99_cloudstack.cfg
sudo sed -i s/" - set-passwords"/" - [set-passwords, always]"/g /etc/cloud/cloud.cfg
echo "system_info:
  default_user:
    name: root
    lock_passwd: false
    sudo: [\"ALL=(ALL) ALL\"]
disable_root: 0
ssh_pwauth: 1" > /etc/cloud/cloud.cfg.d/80_root.cfg
sudo sed -i s/" - ssh$"/" - [ssh, always]"/g /etc/cloud/cloud.cfg
echo "ssh_deletekeys: false" > /etc/cloud/cloud.cfg.d/49_hostkeys.cfg
userdel -r cloud-user
rm -rf /var/lib/cloud/*
rm -f /etc/ssh/*key*
apt-get clean all
cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
rm -f /var/log/*-* /var/log/*.gz 2>/dev/null
history -c
unset HISTFILE