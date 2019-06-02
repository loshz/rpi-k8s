#!/usr/bin/env bash

set -o errexit

function usage {
	echo "Usage: $(basename $0) [BLOCK DEVICE] [IMAGE] [SSH KEY] [HOSTNAME] [IP OCTET]"
	echo "Flash and configure Raspberry Pi host."
	echo ""
	echo "Required params:"
	echo "  inc    increase the brightness +20%"
	echo "  dec    decrease the brightness -20%"
	exit 1
}

function confirm {
	read -p ":: Proceed? [y/N] " CONFIRM
	if [ "${CONFIRM}" != "y" ]; then
		exit 1
	fi
}

# Check script is ran as root
if [[ $EUID > 0 ]]; then
	echo "$(basename $0) must be ran as root"
	exit 1
fi

BLOCK_DEVICE=$1
IMAGE=$2
SSH_KEY=$3
HOSTNAME=$4
IP_OCTET=$5
MNT_RPI=/mnt/rpi
MNT_BOOT=${MNT_RPI}/boot
MNT_ROOT=${MNT_RPI}/root
PI_HOME=${MNT_ROOT}/home/pi

# Check for all required params
if [[ -z ${BLOCK_DEVICE} ]] || [[ -z ${IMAGE} ]] || [[ -z ${SSH_KEY} ]] || [[ -z ${HOSTNAME} ]] || [[ -z ${IP_OCTET} ]]; then
	usage
fi

# Attempt to write image to block device
echo "Will attempt to write image: ${IMAGE} to: ${BLOCK_DEVICE}"
confirm
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
chown -R pi:pi ${PI_HOME}/.ssh
touch ${MNT_BOOT}/ssh
echo -ne "ok\r\n"

# Configure hostname
echo -ne "Configuring hostname..."
sed -ie s/raspberrypi/${HOSTNAME}/g ${MNT_ROOT}/etc/hostname
sed -ie s/raspberrypi/${HOSTNAME}/g ${MNT_ROOT}/etc/hosts
echo -ne "ok\r\n"

# Configure dhcp
echo -ne "Configuring dhcp..."
sed s/XXX/${IP_OCTET}/g ./files/dhcpcd.conf > ${MNT_ROOT}/etc/dhcpcd.conf
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
