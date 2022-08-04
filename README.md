# Terraform Kubernetes Server

This is the Terraform-driven setup for my Kubernetes Server.

## Terraform Setup

Terraform & TFLint must be installed on the development machine.

```bash
brew install terraform tflint
```

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

### Change Kubernetes Context

Use the following command to change the selected Kubernetes context.

```bash
kubectl config use-context kind-kind
```

### Running Terraform

For the dev environment, the `./dev.sh` script has been setup. This is a shortcut to enforcing the use of the Dev (aka Kind) Kubernetes with Terraform. This script can take whatever arguments `terraform` would.

### Working With NodePorts

All node ports must be exposed via a mapping in the `kind-config.yml`. Otherwise they will not be accessible locally.

## Secrets

All secrets need to be stored in a file called `secrets.tfvars` at the root of the project. It should look like this:

```hcl
database_cert = "####"
database_key = "####"
```

# TODO mention 1password creds, base64 encoded, etc

## Debugging

Set `TF_LOG=DEBUG` prior to running any terraform commands to see debug logs. Kubernetes can cause terraform to hang if the container crashes.