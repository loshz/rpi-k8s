#!/usr/bin/env bash

# Install Docker
# TODO: This script exits 1 at the end, find workaround
curl -sSL get.docker.com | sh && \
  sudo usermod pi -aG docker
newgrp docker

# Disable swap
echo -ne "Disabling swap..."
sudo dphys-swapfile swapoff && \
  sudo dphys-swapfile uninstall && \
  sudo update-rc.d dphys-swapfile remove
echo -ne "ok\r\n"

# Enable cgroup memory
echo "Enaling cgroup memory..."
sudo echo "cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" >> /boot/cmdline.txt
echo -ne "ok\r\n"

echo "Rebooting..."
sudo reboot
