# Setup Kubernetes Environment

There are manual steps necessary for setting up the Dev & Prod environments before they will be able to interact with Terraform. This guide covers those steps.

## Table of Contents

1. [Setup MicroK8s](#setup-microk8s)
   1. [Installing MicroK8s](#installing-microk8s)
   2. [Configuring MicroK8s](#configuring-microk8s)
   3. [Additional Production Configuration](#additional-production-configuration)
2. [Configuring the Dev Machine for Multiple Kubernetes Clusters](#configuring-the-dev-machine-for-multiple-kubernetes-clusters)
   1. [Install Kubectl](#install-kubectl)
   2. [Prepare Kubectl Configuration](#prepare-kubectl-configuration)
   3. [Switching Between Clusters](#switching-between-clusters)

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

### Additional Production Configuration

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

To select the cluster to work with on the dev machine, use the following command:

```bash
kubectl config use-context ${microk8s-dev OR microk8s-prod}
```