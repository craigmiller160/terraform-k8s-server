# Deploying the Infrastructure

Once everything is setup, it's time to deploy the infrastructure.

## Table of Contents
# TODO write this part

## Understanding the Modular Design

The infrastructure here has been organized in a modular fashion. This was done for a reason and has some things that need to be understood about it.

### Why Modular?

1. There are certain parts of the infrastructure that couldn't be completely automated or made to go all in one shot. Therefore separate stages were a necessity.
2. Terraform can struggle to properly plan massive deployments across a variety of systems. Smaller modules means a more efficient and effective Terraform deployment.

### Module Ordering

When creating & destroying infrastructure, there is an order that must be respected. This is because different modules depend on the result of previous modules. When updating an existing module, for the most part it can be done independently of the rest, unless a change in it will impact another module. In that case, the ordering rules here must be respected.

1. k8s_custom_resources
2. 1password
3. databases
4. nexus_deployment
5. nexus_config
6. ingress






## Three-Phase Process

Due to limitations in Terraform, the deployment had to be split into three separate phases. Each phase will be described in this document, including what the phase contains and why it needs to be separated. In general the phases need to be run in order for them to work, however after the initial deployment they can be updated individually in most cases.

## Dev vs Prod Deployments

The `{env]` argument in all command examples is for specifying `dev` vs `prod`, which will control the deployment destination.

## Phase 1

### What it Contains

- 1Password Custom Kubernetes Resource Definition

### Why is it Separate?

The Terraform Kubernetes Provider will not execute a plan with an unknown resource definition. 1Password requires a custom resource definition to be configured as part of its Kubernetes deployment. Therefore this needs to be deployed as a separate infrastructure plan.

### How to Deploy

Use the `tf.sh` script to deploy the phase:

```bash
./tf.sh {env} phase1 apply
```

## Phase 2

### What it Contains

- Postgres Database
- MongoDB Database
- Nexus Artifact Repository
- 1Password Sync/Connect/Operator For Injecting Secrets

### Why is it Separate?

This phase is the "base" of the infrastructure. Everything that could be deployed in one plan is here. It is the second phase because of the pre-requisites for 1Password.

### How to Setup

The 1Password credentials and token must be provided as Terraform secret variables in order to run this phase.

First, get the values from 1Password. They can be found in "Tech Stuff" -> "Home Server Production Credentials" and "Tech Stuff" -> "Home Server Production Access Token".

Second, Base64 encode the credentials JSON file.

Third, create the file `./phase2/secrets.tfvars` and put the two values into it like this:

```hcl
onepassword_creds = "####"
onepassword_token = "####"
```

### How to Deploy

Use the `tf.sh` script to deploy the phase:

```bash
./tf.sh {env} phase2 apply
```

## Phase 3

### What it Contains

- All Configuration for Nexus

### Why is it Separate?

Sonatype Nexus, upon first deployment, requires an admin password. This password cannot be set via container configuration, it is randomly generated at first startup and available as a file within the container. Because of this, manually retrieving this password is required before being able to run the Nexus configuration.

### How to Setup

After the Nexus pod is running, ssh into it and grab the password from its file

```bash
kubectl exec -it nexus-PodHash -- bash
cat /nexus-data/admin.password
```

Using this password, open the Nexus UI and log in with it. There will be a prompt to immediately change this password. Change it to the password found in 1Password at "Tech Stuff" -> "Nexus Repository (Admin)".

Once this is complete, take the new Admin password and the password found in "Tech Stuff" -> "Nexus Repository (Craig)" and place them into a Terraform secret variables file, `./phase3/secrets.tfvars`. It should look like this:

```hcl
nexus_admin_password = "####"
nexus_craig_password = "####"
```

### How to Deploy

Use the `tf.sh` script to deploy the phase:

```bash
./tf.sh {env} phase3 apply
```