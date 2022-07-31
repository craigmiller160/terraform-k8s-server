#!/bin/sh

terraform $@ \
  -backend-config="config_context=kind" \
  -var="k8s_context=kind" \
  -var-file="secrets.tfvars"