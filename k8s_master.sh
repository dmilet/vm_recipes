#! /bin/sh

#####################
# K8S MASTER
#####################
# Disable floppy
# 2 CPU at least
# 2GB RAM,
# 40GB /sda for OS
# Network 1 : NAT
# Network 2 : Host-only
# Disable Audio
#
# Create VirtualBox VM from CentOS7 DVD
#  Minimal install, System Administration Tools
#  Automatic partitioning for /sda
#  Enable network interfaces enp0s3 (NAT, DHCP), enp0s8 (Host-only, DHCP)
#  set hostname=master

########################
# GENERAL STUFF
########################

./generic_vb_vm_settings.sh

sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
setenforce 0

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
# do not use the nftables backend
update-alternatives --set iptables /usr/sbin/iptables-legacy


cat << EOF > /etc/sysctl.d/master.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

yum -y install docker

systemctl enable docker
systemctl start docker

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet
kubeadm init --v=5 --control-plane-endpoint=master  --pod-network-cidr=10.244.0.0/16

# Copy configuration to make kubectl command work
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy network plugin
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl get pods --all-namespaces


