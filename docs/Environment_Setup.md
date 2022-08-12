# Environment Setup

There are manual steps necessary for setting up the Dev & Prod environments before they will be able to interact with Terraform. This guide covers those steps.

## Table of Contents

1. [Dev Environment](#dev-environment)
2. [Prod Environment](#prod-environment)
3. [Kubectl - Switching Between Environments](#kubectl---switching-between-environments)

## Dev Environment

The dev environment is a much more limited Kubernetes cluster that can run on a dev machine and experiment with changes before deploying them to the final cluster. The expectation is that the development machine will be a MacOS device.

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

The production environment will run on my home Ubuntu machine and use MicroK8s as the Kubernetes provider. Here are the steps to set it up. Please note that unless specified otherwise, these steps must be performed on the Ubuntu machine.

### Install & Configure MicroK8s

MicroK8s must be installed on the machine. The Snap tool is required to do so.

```bash
sudo snap install microk8s --classic --channel=1.24
```

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



## Kubectl - Switching Between Environments

One thing to keep in mind is that the dev & prod environments are both Kubernetes clusters. It is simple to switch between them using the `kubectl` tool. Keep in mind that the environments must be setup first for this to work. Also, since the dev environment only exists on the dev machine, this is expected to only be run on the dev machine.

```bash
# Use dev environment
kubectl config use-context kind-kind
# Use prod environment
kubectl config use-context microk8s
```