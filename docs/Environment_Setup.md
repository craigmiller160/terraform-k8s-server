# Setup Kubernetes Environment (Deprecated, Needs Re-Write)

There are manual steps necessary for setting up the Dev & Prod environments before they will be able to interact with Terraform. This guide covers those steps.

## Table of Contents
# TODO re-write this

1. [Dev Environment](#dev-environment)
   1. [Install Kubectl](#install-kubectl)
   2. [Install Kind](#install-kind)
   3. [Create a Cluster](#create-a-cluster)
2. [Prod Environment](#prod-environment)
   1. [Install MicroK8s](#install-microk8s)
   2. [Configure MicroK8s](#configure-microk8s)
   3. [Allow Dev Machine to Access Prod Kubernetes](#allow-dev-machine-to-access-prod-kubernetes)
3. [Switching Between Kubernetes Environments](#switching-between-kubernetes-environments)

## Setup MicroK8s

MicroK8s is the Kubernetes solution being used in all environments. It is a fully featured Kubernetes solution.

### Installing MicroK8s

To install MicroK8s, use the commands that are appropriate for the environment.

**Dev**
```bash
brew install ubuntu/microk8s/microk8s
microk8s install or microk8s install --channel 1.24
```

**Prod**
```bash
sudo snap install microk8s --classic --channel=1.24
```

### Configuring MicroK8s

MicroK8s requires several addons to be enabled to ensure its full capabilities. Please note that on prod `sudo` is needed for the `microk8s` commands to work:

```bash
microk8s enable ingress dns dashboard storage registry helm3
```

## Additional Production Configuration

Aliases for MicroK8s commands should be added on the production server:

```bash
sudo snap alias microk8s.helm3 helm3
sudo snap alias microk8s.kubectl kubectl
```

Lastly, add `kubectl` auto-completion to the machine's bash setup file:

```bash
source <(kubectl completion bash)
```

## Configuring the Dev Machine for Multiple Kubernetes Clusters

There are several steps that are necessary to prepare the dev machine to work with multiple kubernetes clusters.

### Install Kubectl

The Kubernetes `kubectl` tool needs to be installed on the dev machine. It can be done so with this command:

```bash
brew install kubernetes-cli
```

### Prepare Kubectl Configuration

The `kubectl` tool knows which cluster to speak to because of a configuration file that contains this information. This file must be setup with all information for both the dev & prod clusters.

The configuration for the dev & prod clusters can both be found by running this command on their respective machines. Remember that prod needs `sudo`:

```bash
microk8s config
```

The values from this configuration need to be placed into the `~/.kube/config` file following this format, substituting all values in `${}`.

```yaml
apiVersion: v1
kind: Config
preferences: {}
clusters:
  - cluster:
     certificate-authority-data: ${value from dev}
     server: ${value from dev}
    name: microk8s-dev
  - cluster:
      certificate-authority-date: ${value from prod}
      server: ${value from prod}
    name: microk8s-prod
contexts:
  - context:
      cluster: microk8s-dev
      user: admin-dev
    name: microk8s-dev
  - context:
      cluster: microk8s-prod
      user: admin-prod
    name: microk8s-prod
users:
  - name: admin-dev
    user:
      token: ${value from dev}
  - name: admin-prod
    user:
      token: ${value from prod}
```

### Switching Between Clusters






## Dev Environment

The dev environment is a much more limited Kubernetes cluster that can run on a dev machine and experiment with changes before deploying them to the final cluster. The expectation is that the development machine will be a MacOS device.

### Install Kubectl

The Kubernetes `kubectl` tool needs to be installed on the dev machine. It can be done so with this command:

```bash
brew install kubernetes-cli
```

### Install MicroK8s

MicroK8s is the Kubernetes solution being used in prod, so it will be used in dev as well. It is a fully featured Kubernetes solution.  It has a multi-step installation process.



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

microk8s enable ingress dns dashboard storage registry helm3
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