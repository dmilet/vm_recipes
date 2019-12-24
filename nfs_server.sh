#! /bin/sh

#####################
# NFS SERVER 
#####################
# Disable floppy
# 1GB RAM, 
# 40GB /sda for OS
# 20GB /sdb for data
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

pvcreate /dev/sdb
vgcreate vgNFS /dev/sdb
lvcreate -L 20476M -n lvNFS /dev/vgNFS
mkfs.xfs /dev/mapper/vgNFS-lvNFS
mkdir -p /nfsexport

sed -i '/nfsexport/d' /etc/fstab
cat >> /etc/fstab << FSTAB
/dev/mapper/vgNFS-lvNFS /nfsexport xfs defaults 0 0
FSTAB
mount -a

# start nfs services
chkconfig nfs on
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap


cat > /etc/exports.d/local.exports << EXPORTS
/nfsexport *(rw,sync,no_root_squash,insecure)
EXPORTS
exportfs -fra
exportfs -v
    

