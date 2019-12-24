#!/bin/sh

#########################
# General configuration
# for all VB VMs
#########################

# autoconnect host-only interface
nmcli connection modify enp0s8 connection.autoconnect yes
nmcli device connect enp0s8

# get ip address
ip=$(ip -4 addr | grep -e "enp0s8$"| cut -f 1 -d "/" | awk '{print $NF}')
echo $ip $(hostname) >> /etc/hosts


########################
# GENERAL STUFF
########################
yum -y install \
    epel-release \
    curl \
    wget \
    net-tools \
    git \
    nfs-utils

# install prerequisites for VirtualBox guest additions
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y perl gcc dkms kernel-devel kernel-headers make bzip2
yum update -y

# enable firewall and add enp0s8 to trusted zone
systemctl start firewalld
systemctl enable firewalld

firewall-cmd --set-log-denied all
firewall-cmd --permanent --zone=trusted --add-interface=enp0s8
firewall-cmd --complete-reload


sed -i '/swap/d' /etc/fstab
swapoff -a

sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
