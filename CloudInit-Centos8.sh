#!/bin/bash
# Description: update OS and install and configure cloud-init as a Cloudstack middlewere

## Update OS and insatll cloud-init + auxiliary packages
yum -y update 
yum -y install cloud-init

## Network cleanup
echo "DEVICE=eth0
TYPE=Ethernet
BOOTPROTO=dhcp
ONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-eth0

## set neutral hostname
hostname localhost
echo "localhost" > /etc/hostname

## Define cloud-init data source
echo "datasource: CloudStack" > /etc/cloud/ds-identify.cfg

## Enable password integration
sudo sed -i s/" - set-passwords"/" - [set-passwords, always]"/g /etc/cloud/cloud.cfg
sudo sed -i s/" - scripts-user"/" - [scripts-user, always]"/g /etc/cloud/cloud.cfg

echo "system_info:
  default_user:
    name: root
    lock_passwd: false
    sudo: [\"ALL=(ALL) ALL\"]
disable_root: 0
ssh_pwauth: 1" > /etc/cloud/cloud.cfg.d/80_root.cfg

## Enable SSH keys integration
sudo sed -i s/" - ssh$"/" - [ssh, always]"/g /etc/cloud/cloud.cfg
echo "ssh_deletekeys: false" > /etc/cloud/cloud.cfg.d/49_hostkeys.cfg

## Template Cleanup
rm -rf /var/lib/cloud/data/*
rm -rf /var/lib/cloud/instance/*
rm -rf /var/lib/cloud/instances/*

### remove address bindings as they are generated on boot
rm -f /etc/udev/rules.d/70*
rm -f /var/lib/dhclient/*

### remove ssh keys for security purposes
rm -f /etc/ssh/*key*

### clean logs
yum clean all
cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
rm -f /var/log/*-* /var/log/*.gz 2>/dev/null

### Clearing User History
history -c
unset HISTFILE
