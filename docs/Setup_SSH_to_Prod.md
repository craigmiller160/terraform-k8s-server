# Setup SSH Access to Prod Machine

The Prod Machine needs to be setup with SSH so that the Dev Machine can easily access it. Here is how to do it.

## Table of Contents

## Install OpenSSH on Prod Server

To install OpenSSH, use the following commands:

```bash
sudo apt update
sudo apt install openssh-server
```

At this point, the SSH server should be working with Password authentication. This will be changed later on.

## Configure Dev Machine SSH Client