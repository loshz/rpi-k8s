#!/usr/bin/env bash

set -o errexit

# Check script is ran as root
if [[ $EUID > 0 ]]; then
	echo "$(basename $0) must be ran as root"
	exit 1
fi

MNT_RPI=/mnt/rpi
MNT_BOOT=${MNT_RPI}/boot
MNT_ROOT=${MNT_RPI}/root
PI_HOME=${MNT_ROOT}/home/pi

read -p "Enter full path of block device (eg. /dev/sda): " BLOCK_DEVICE
read -p "Enter full path of OS image: " IMAGE
read -p "Enter full path of public SSH Key (eg. /path/to/key.pub): " SSH_KEY
read -p "Enter hostname: " HOSTNAME
read -p "Enter last octet for IP address (192.168.0.XYZ): " IP_OCTET

# Check for all required params
if [[ -z ${BLOCK_DEVICE} ]] || [[ -z ${IMAGE} ]] || [[ -z ${SSH_KEY} ]] || [[ -z ${HOSTNAME} ]] || [[ -z ${IP_OCTET} ]]; then
	echo "Please enter a value for all required fields"
	exit 1
fi

# Attempt to write image to block device
echo "Writing image: ${IMAGE} to: ${BLOCK_DEVICE}..."
dd bs=4M if=${IMAGE} of=${BLOCK_DEVICE} status=progress conv=fsync
sync

# Mount boot and root dirs
echo -ne "\nMounting block device from ${BLOCK_DEVICE}..."
mkdir -p ${MNT_BOOT} ${MNT_ROOT}
mount ${BLOCK_DEVICE}1 ${MNT_BOOT}
mount ${BLOCK_DEVICE}2 ${MNT_ROOT}
echo -ne "ok\r\n"

# Configure SSH
echo -ne "Configuring SSH..."
mkdir -p ${PI_HOME}/.ssh
cat ${SSH_KEY} > ${PI_HOME}/.ssh/authorized_keys
touch ${MNT_BOOT}/ssh
echo -ne "ok\r\n"

# Configure hostname
echo -ne "Configuring hostname..."
sed -ie s/raspberrypi/${HOSTNAME}/g ${MNT_ROOT}/etc/hostname
sed -ie s/raspberrypi/${HOSTNAME}/g ${MNT_ROOT}/etc/hosts
echo -ne "ok\r\n"

# Configure config
echo -ne "Configuring config..."
# Reduce GPU memory to minimum
echo "gpu_mem=16" >> ${MNT_ROOT}/config.txt 
echo -ne "ok\r\n"

# Configure dhcp
echo -ne "Configuring dhcp..."
sed s/XYZ/${IP_OCTET}/g ./files/dhcpcd.conf > ${MNT_ROOT}/etc/dhcpcd.conf
echo -ne "ok\r\n"

# Copy scripts
echo -n "Copy scripts to ${PI_HOME}/bin..."
cp -r ./bin ${PI_HOME}
echo -ne "ok\r\n"

# Unmount block device
echo -ne "Unmounting block device from ${MNT_RPI}..."
umount ${MNT_BOOT}
umount ${MNT_ROOT}
rm -r ${MNT_RPI}
sync
echo -ne "ok\r\n"
