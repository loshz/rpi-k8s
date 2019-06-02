#!/usr/bin/env bash

set -o errexit

# Install kubeadm
echo "Adding Kubernetes to source list..."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt update -q && \
  sudo apt install -qy kubeadm

# Install additional packages
sudo apt install -qy neovim
sudo apt install -qy jq
sudo apt install -qy lsof
sudo apt install -qy dnsutils
sudo apt install -qy traceroute
sudo apt install -qy tcpdump

# Cleanup
sudo apt autoremove -y
sudo rm -rf /var/lib/apt/lists/*
