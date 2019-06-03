# rpi-k8s

A set of scripts for provisioning and running Kubernetes on a Raspberry Pi cluster.

- [scripts](scripts): scripts for provisioning nodes.
- [spec](spec): all Kubernetes related yaml.

## Installation

### Provision SD card.

1. Download the Raspbian Lite image from the [Raspberry Pi website](https://www.raspberrypi.org/downloads/raspbian/).
2. Insert SD card and run `lsblk` to get block device name. Eg. `/dev/sda`.
3. Run [./flash.sh](scripts/flash.sh) script and provide the relevant paths and config.

### Master Node

1. Boot Pi from the flashed SD card.
2. SSH onto the Pi: `ssh pi@[IP address]`.
3. `cd` into `$HOME/bin`.
4. Provision node using: `./bootstrap.sh` - **Note:** This script will reboot the Pi.
5. Install required packages using: `./packages.sh`.
6. Initialise master node using: `./master.sh`.

Once all scripts have ran successfully, validate the master node is showing a "Ready" status: `kubectl get nodes`.

### Worker Node

1. Boot Pi from the flashed SD card.
2. SSH onto the Pi: `ssh pi@[IP address]`.
3. `cd` into `$HOME/bin`.
4. Provision node using: `./bootstrap.sh`. **NOTE:** This script will reboot the Pi.
5. Install required packages using: `./packages.sh`.
6. Log out.

After provisioning the new node, you will need to generate a new join token for [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/).

1. SSH onto the master node: `ssh pi@[IP address]`.
2. Generate a new token: `kubeadm token generate`.
3. Initialise the new token: `kubeadm token create [TOKEN]`.
4. Log out.

Once you have the new token and hash:

1. SSH onto the new worker node.
2. `cd` into `$HOME/bin`.
3. Initialise worker node using: `./worker.sh`.

Once the worker node has successfully joined the cluster, validate the worker node is showing a "Ready" status: `kubectl get nodes`.
