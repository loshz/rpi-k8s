#!/usr/bin/env bash

set -o errexit

# Pre-pull required images
sudo kubeadm config images pull -v3

# Init master
sudo kubeadm init --token-ttl=0 --pod-network-cidr=10.244.0.0/16

# Copy admin conf
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl

# Install Flannel CNI
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
