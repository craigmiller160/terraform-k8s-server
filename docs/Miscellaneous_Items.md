# Miscellaneous Items

Just some random items that don't fit in other sections.

## Table of Contents

1. [DNS Hostname](#dns-hostname)
2. [Let's Encrypt TLS](#lets-encrypt-tls)
3. [Debugging Terraform](#debugging-terraform)

## DNS Hostname

The `craigmiller160.ddns.net` hostname comes from the [NoIP](https://www.noip.com/) service. It can be managed at that link.

## Let's Encrypt TLS

The public TLS cert comes from Let's Encrypt. There is a separate repo with instructions on how to manage this. I'm leaving this section vague because of plans to further integrate Let's Encrypt into this terraform project.

## Debugging Terraform

Set `TF_LOG=DEBUG` prior to running any `tf.sh` commands to see debug logs.