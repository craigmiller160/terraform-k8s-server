#!/bin/sh

backend_arg=""
if [ $1 == "init" ]; then
  backend_arg = "-backend-config='config_context=kind'"
fi

terraform $@ \
  -var="k8s_context=kind" \
  -var-file="secrets.tfvars" \
  $backend_arg