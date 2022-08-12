# Terraform Kubernetes Server

This is the Terraform-driven setup for my Kubernetes Server.

## Table of Contents

1. [Setup Kubernetes Environment](./docs/Environment_Setup.md)
2. [Setup Port Forwarding](./docs/Port_Forwarding.md)
3. [Setup SSH Access to Prod Machine](./docs/Setup_SSH_to_Prod.md)
4. [Miscellaneous Items](./docs/Miscellaneous_Items.md)

# TODO everything below here is old

## Three-Phase Setup

Due to limitations on some of the infrastructure being setup, Terraform will construct everything in a three-phase process.

Phase 1 = Custom Kubernetes Type for 1Password Integration

Phase 2 = Setup of key environment applications, secrets, and other resources

Phase 3 = Special setup of Sonatype Nexus since a manual step is required first.

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

OUTDATED, RE-WRITE THIS

For the dev environment, the `./tf.sh` script has been setup. This is a shortcut to enforcing the use of the Dev (aka Kind) Kubernetes with Terraform. This script can take whatever arguments `terraform` would.

### Working With NodePorts

All node ports must be exposed via a mapping in the `kind-config.yml`. Otherwise they will not be accessible locally.

## Secrets

Terraform needs certain secrets in order to operate. These secrets must be manually setup locally in this repository prior to running the application. Secrets must be stored in a file called `secrets.tfvars` in the appropriate phase directory.

### Phase 2 Secrets

```hcl
# Both of the onepassword secrets are the values after being Base64 encoded 
onepassword_creds = "####"
onepassword_token = "####"
```

## Debugging

Set `TF_LOG=DEBUG` prior to running any terraform commands to see debug logs. Kubernetes can cause terraform to hang if the container crashes.

# Heavily clean up this readme. Add stuff about the Nexus Admin user setup manual step. Also transfer over the stuff for local development integration from the old docs