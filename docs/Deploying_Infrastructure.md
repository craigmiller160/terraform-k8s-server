# Deploying the Infrastructure

Once everything is setup, it's time to deploy the infrastructure.

## Table of Contents

1. [Understanding the Modular Design](#understanding-the-modular-design)
   1. [Why Modular?](#why-modular)
   2. [Module Ordering](#module-ordering)
2. [Executing Deployments](#executing-deployments)
   1. [Checking All Statuses](#checking-all-statuses)
   2. [Executing Module Plans](#executing-module-plans)
3. [Manual Steps](#manual-steps)
   1. [1Password Module](#1password-module)
   2. [Nexus_Config Module](#nexus_config-module)

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

## Executing Deployments

The steps to execute the deployments are the same for all modules.

### Checking All Statuses

There is a script in the root of the project that will go through all the modules and check the status of their plans to report if any changes need to be executed. It is run like this:

```bash
./all_plans.sh {dev or prod}
```

### Executing Module Plans

All terraform commands are properly executed via a shell script in each module. The scripts can easily be invoked from the root of the project. This is done in the following way:

```bash
# Initialize the module if not done already
./module_directory/tf.sh init
# Apply all configuration changes for the module
./module_directory/tf.sh apply
# Remove all configuration from the module
./module_directory/tf.sh destroy
```

## Manual Steps

Not everything can be automated. Some modules require manual intervention. These are the modules that require it.

### 1Password Module

The 1Password credentials and token must be provided as Terraform secret variables in order to run this phase.

First, get the values from 1Password. They can be found in "Tech Stuff" -> "Home Server Production Credentials" and "Tech Stuff" -> "Home Server Production Access Token".

Second, Base64 encode the credentials JSON file.

Third, create the file `./1password/secrets.tfvars` and put the two values into it like this:

```hcl
onepassword_creds = "####"
onepassword_token = "####"
```

### Nexus_Config Module

After the Nexus pod is running, ssh into it and grab the password from its file

```bash
kubectl exec -it nexus-PodHash -- bash
cat /nexus-data/admin.password
```

Using this password, open the Nexus UI and log in with it. There will be a prompt to immediately change this password. Change it to the password found in 1Password at "Tech Stuff" -> "Nexus Repository (Admin)".

Once this is complete, take the new Admin password and the password found in "Tech Stuff" -> "Nexus Repository (Craig)" and place them into a Terraform secret variables file, `./nexus_config/secrets.tfvars`. It should look like this:

```hcl
nexus_admin_password = "####"
nexus_craig_password = "####"
```

Also. the `./scripts/dev.env` file may have the wrong IP address for the Nexus host (if running for dev). This is because every time MicroK8s is installed on dev its IP changes, and that's the IP used to access the Nexus UI. To find out the IP address of microk8s, run this command:

```bash
multipass list
```