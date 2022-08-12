# Kubernetes Environment Setup

There are manual steps necessary for setting up the Dev & Prod environments before they will be able to interact with Terraform. This guide covers those steps.

## Table of Contents

1. [Dev Environment](#dev-environment)
   1. [Install Kubectl](#install-kubectl)
   2. [Install Kind](#install-kind)
   3. [Create a Cluster](#create-a-cluster)
2. [Prod Environment](#prod-environment)
   1. [Install MicroK8s](#install-microk8s)
   2. [Configure MicroK8s](#configure-microk8s)
   3. [Allow Dev Machine to Access Prod Kubernetes](#allow-dev-machine-to-access-prod-kubernetes)
3. [Switching Between Kubernetes Environments](#switching-between-kubernetes-environments)

## Dev Environment

The dev environment is a much more limited Kubernetes cluster that can run on a dev machine and experiment with changes before deploying them to the final cluster. The expectation is that the development machine will be a MacOS device.

### Install Kubectl

The Kubernetes `kubectl` tool needs to be installed on the dev machine. It can be done so with this command:

```bash
brew install kubernetes-cli
```

### Install Kind

Kind is a lightweight Kubernetes service that runs well on MacOS. It runs as a Docker container, so before doing anything with it make sure Docker is running. Install it with:

```bash
brew install kind
```

Once installed, the container will be set to automatically start whenever Docker does.

### Create a Cluster

Kind will be used to create a Kubernetes cluster. There is a configuration file in the root of this project that needs to be used to properly configure the cluster.

```bash
kind create cluster --config=./kind-config.yml
```

## Prod Environment

The production environment will run on my home Ubuntu machine and use MicroK8s as the Kubernetes provider. Here are the steps to set it up.

### Install MicroK8s

MicroK8s must be installed on the Ubuntu machine. The Snap tool is required to do so. All of these steps must be executed on the Ubuntu production machine.

```bash
sudo snap install microk8s --classic --channel=1.24
```

### Configure MicroK8s

Once it is installed, it must be configured. First, addons need to be enabled:

```bash
sudo microk8s enable dns
sudo microk8s enable dashboard
sudo microk8s enable storage
sudo microk8s enable registry
sudo microk8s enable helm3
```

Then, aliases for MicroK8s commands should be added:

```bash
sudo snap alias microk8s.helm3 helm3
sudo snap alias microk8s.kubectl kubectl
```

Lastly, add `kubectl` auto-completion to the machine's bash setup file:

```bash
source <(kubectl completion bash)
```

### Allow Dev Machine to Access Prod Kubernetes

On the dev machine, once `kubectl` is installed, there either will be a `~/.kube/config` file, or it needs to be created. Either way, the following changes must be made. There are some values that must be retrieved from the production Ubuntu machine. Those values can be found at the exact same paths in an identically-formatted yaml file at `/var/snap/microk8s/current/credentials/client.config`.

```yaml
# Under the clusters section, we must add the cluster
clusters:
  - cluster:
      certificate-authority-data: {FROM PROD SERVER}
      server: https://kubernetes:16443
    name: microk8s-cluster

# Under the contexts section, we must add the cluster as a context
contexts:
  - context:
      cluster: microk8s-cluster
      user: admin
    name: microk8s

# Under the users section, we need our admin user
users:
  - name: admin
    user:
      token: {FROM PROD SERVER}
```

NOTE: The `kubernetes` hostname under `clusters.cluster.server` is a placeholder for the internal LAN IP of the Ubuntu machine.

## Switching Between Kubernetes Environments

One thing to keep in mind is that the dev & prod environments are both Kubernetes clusters. It is simple to switch between them using the `kubectl` tool. Keep in mind that the environments must be setup first for this to work. Also, since the dev environment only exists on the dev machine, this is expected to only be run on the dev machine.

```bash
# Use dev environment
kubectl config use-context kind-kind
# Use prod environment
kubectl config use-context microk8s
```