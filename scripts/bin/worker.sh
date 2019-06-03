#!/usr/bin/env bash

set -o errexit

read -p "Token: " TOKEN
read -p "Token CA Cert Hash: " HASH
read -p "Master node IP address: " MASTER_ADDR

kubeadm join ${MASTER_ADDR}:6443 --token ${TOKEN} \
    --discovery-token-ca-cert-hash ${HASH}

# Copy admin conf
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel CNI
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sudo sysctl net.bridge.bridge-nf-call-iptables=1
