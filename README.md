# rpi-k8s

A set of scripts for provisioning and running Kubernetes on a Raspberry Pi cluster.

> **WARNING:** As this cluster is intended to run locally, certain security aspects have been ignored. This setup is NOT intended to be ran in a production environment!

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

After provisioning the new node, you will need to generate a new [kubeadm join token](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/):

1. SSH onto the master node: `ssh pi@[IP address]`.
2. Create a new token: `kubeadm token create --print-join-command`.
3. Log out.

Once you have the new token and hash:

1. SSH onto the new worker node.
2. Run the `kubeadm join` command generated on the master node.

Once the worker node has successfully joined the cluster, validate the worker node is showing a "Ready" status: `kubectl get nodes`.

## Configuration

Several yaml files have been provided to make it easier to configure some core monitoring applications for the cluster. In most cases, these yaml files are direct copies of the default yaml files provided by the owner, with a change to use an ARM image.

### Kubernetes Dasboard

Deploy the dashboard using:
```
kubectl apply -f spec/kubernetes/dashboard/dashboard.yml
```

Check that the dashboard pod is running:
```
kubectl get pods -n=kube-system | grep "dashboard"
```

Once running, proxy the API server and visit the [dashboard](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/):
```
kubectl proxy
```

More specific information can be found in the [official documentation](https://github.com/kubernetes/dashboard).

### kube-state-metrics

Deploy the metrics generator using:
```
kubectl apply -f spec/kubernetes/kube-state-metrics/kube-state-metrics.yml
```

More specific information can be found in the [official documentation](https://github.com/kubernetes/kube-state-metrics).

### Prometheus

**Note:** For simplicity, the included Prometheus yaml uses a Deployment instead of a StatefulSet. Therefore, any persisting data or changes made to the config via the UI, will be deleted if the pod is to restart.

Deploy Prometheus:
```
kubectl apply -f spec/prometheus/prometheus.yml
```

Check that the dashboard pod is running:
```
kubectl get pods | grep "prometheus"
```

Once running, port-forward the pod and visit the [dashboard](http://localhost:9090):
```
kubectl port-forward prometheus-xxxx-xxx 9090
```

By default, several scrape-configs have been included for the followings jobs:
- kubernetes-apiservers
- kubernetes-nodes
- kubernetes-cadvisor
- kubernetes-service-endpoints
- kubernetes-services
- kubernetes-pods

You should be able to query metrics after 30s.

More specific information can be found in the [official documentation](https://prometheus.io/).
