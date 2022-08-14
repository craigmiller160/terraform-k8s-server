#!/bin/bash

source ./scripts/terraform.sh

if [ $# -lt 3 ]; then
  echo "Must specify environment, phase, & terraform command"
  exit 1
fi

run_terraform $@