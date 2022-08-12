# Setup SSH Access to Prod Machine

The Prod Machine needs to be setup with SSH so that the Dev Machine can easily access it. Here is how to do it.

## Table of Contents

1. [Install OpenSSH on Prod Server](#install-openssh-on-prod-server)
2. [Configure Dev Machine SSH Client](#configure-dev-machine-ssh-client)
3. [Setup SSH Key Authentication](#setup-ssh-key-authentication)
4. [Restricting SSH Server to Only Key Authentication](#restricting-ssh-server-to-only-key-authentication)

## Install OpenSSH on Prod Server

To install OpenSSH, use the following commands:

```bash
sudo apt update
sudo apt install openssh-server
```

At this point, the SSH server should be working with Password authentication. This will be changed later on.

## Configure Dev Machine SSH Client

NOTE: This expects that all port forwarding has been configured.

The MacOS dev machine will have an SSH client installed by default. There will be a configuration file at `~/.ssh/config` (or else create one). Set it up like this:

```
Host craigpc
    Hostname craigmiller160.ddns.net
    User craig
    Port 8000
```

Now it should be possible to SSH from this machine to the prod machine using `ssh craigpc`. Please note that the password for the user account on the prod machine will be needed at this point.

## Setup SSH Key Authentication

To setup SSH Key Authentication, the first thing that must be done is to generate the SSH key on the client Dev machine. This is done with the following command:

```bash
ssh-keygen -t ecdsa -b 521

# Output is these files
~/.ssh/id_ecdsa
~/.ssh/id_ecdsa.pub
```

NOTE: Defaults are fine (ie, no passphrase needed).

Then, copy the SSH key to the server with this command. The password for the server's user account is still required.

```bash
ssh-copy-id -i .ssh/id_ecdsa.pub craigpc
```

Now key authentication should be properly setup.

## Restricting SSH Server to Only Key Authentication

To restrict the SSH Server on the Prod Ubuntu machine to only allow Key Authentication, edit the `/etc/ssh/sshd_config` file and turn off password authentication:

```
# Find this key in the file and set it to no
PasswordAuthentication no
```

After saving the changes, restart the server with this command:

```bash
sudo service ssh restart
```

Now the dev machine should be able to log into the prod server without a password because it is validating the key.