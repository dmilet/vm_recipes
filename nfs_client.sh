#! /bin/sh

#####################
# NFS CLIENT
#####################
# Disable floppy
# 1GB RAM, 
# 40GB /sda for OS
# Network 1 : NAT
# Network 2 : Host-only 
# Disable Audio
#
# Create VirtualBox VM from CentOS7 DVD
#  Minimal install, System Administration Tools
#  Automatic partitioning for /sda
#  Enable network interfaces enp0s3 (NAT, DHCP), enp0s8 (Host-only, DHCP)

########################
# GENERAL STUFF
########################  
./generic_vb_vm_settings.sh

systemctl enable rpcbind
systemctl start rpcbind

