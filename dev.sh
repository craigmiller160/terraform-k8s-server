#!/bin/sh

backend_arg=""
if [ $1 == "init" ]; then
  backend_arg = "-backend-config='config_context=kind-kind'"
fi

terraform $@ \
  -var="k8s_context=kind-kind" \
  -var-file="secrets.tfvars" \
  $backend_arg