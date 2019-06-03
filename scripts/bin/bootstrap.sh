#!/usr/bin/env bash

# Install Docker
curl -sSL get.docker.com | sh && \
  sudo usermod pi -aG docker

# Disable swap
echo -ne "Disabling swap..."
sudo dphys-swapfile swapoff && \
  sudo dphys-swapfile uninstall && \
  sudo update-rc.d dphys-swapfile remove
echo -ne "ok\r\n"

# Enable cgroup memory
echo "Enaling cgroup memory..."
echo "$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" | sudo tee /boot/cmdline.txt
echo -ne "ok\r\n"

echo "Rebooting..."
sudo reboot
