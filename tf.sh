#!/bin/bash

# TODO change arguments order, put all terraform commands at end

# -var-file="secrets.tfvars"

function run_for_env {
  backend_arg=""
  var_file=""

  if [ $1 == "init" ]; then
    backend_arg="-backend-config=config_context=$2"
  fi

  if [ -f "$3/secrets.tfvars" ]; then
    var_file="-var-file=secrets.tfvars"
  fi

  (
    cd "$3" &&
    terraform $1 \
        -var="k8s_context=$2" \
        $backend_arg \
        $var_file
  )
}

function parse_args {
  if [ $# -lt 2 ]; then
    echo "Must specify environment"
    exit 1
  fi

  directory="infrastructure"
  context=""

  case $2 in
    "dev") context="kind-kind" ;;
    "prod") context="microk8s" ;;
    *)
      echo "Invalid environment: $2"
      exit 1
    ;;
  esac

  case $3 in
    "") directory="infrastructure" ;;
    "--pre") directory="pre_infrastructure" ;;
    *)
      echo "Invalid argument: $3"
      exit 1
    ;;
  esac

  run_for_env "$1" "$context" "$directory"
}

parse_args $@