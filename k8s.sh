#!/bin/bash

source ./scripts/set-k8s-config.sh

if [ $# -ne 1 ]; then
  echo "Must specify environment for kubernetes"
  exit 1
fi

set_config $1

