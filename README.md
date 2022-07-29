# Terraform Kubernetes Server

This is the Terraform-driven setup for my Kubernetes Server.

## MacOS Development Environment Setup

A few manual steps are necessary to prepare the MacOS development environment for Terraform

### Install Kind

Kind is a Kubernetes service that runs well on MacOS. It runs as a Docker container, so before doing anything with it make sure Docker is running. Install it with:

```bash
brew install kind
```

Once installed, the container will be set to automatically start whenever Docker does.

### Create a Cluster

Kind makes it easy to create a simple cluster. With one command the cluster is created and configured. Run the command in this directory so that the configuration can be used.

```bash
kind create cluster --config=./kind-config.yml
```

### Change Kubernetes Config File

The `~/.kube/config` file has been modified by the Kind installation. A few tweaks are necessary to get it up and running.

1. Find the Context for Kind. Change the `name` from `kind-kind` to `kind` to make it easier to call from Kubectl.
2. If the MicroK8s Kubernetes Server has been added to this device, its configuration should still be here. Change the `current-context` field to `microk8s` so that it is the default again.

### Running Terraform

For the dev environment, the `./dev.sh` script has been setup. This is a shortcut to enforcing the use of the Dev (aka Kind) Kubernetes with Terraform. This script can take whatever arguments `terraform` would.

## Secrets

All secrets need to be stored in a file called `secrets.tfvars` at the root of the project. It should look like this:

```hcl
postgres_root_password = "####"
```

## Debugging

Set `TF_LOG=DEBUG` prior to running any terraform commands to see debug logs. Kubernetes can cause terraform to hang if the container crashes.