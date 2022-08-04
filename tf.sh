#!/bin/bash

function run_for_env {
  backend_arg=""
  var_file=""

  if [ $3 == "init" ]; then
    backend_arg="-backend-config=config_context=$1"
  fi

  if [ -f "$2/secrets.tfvars" ]; then
    var_file="-var-file=secrets.tfvars"
  fi

  (
    cd "$2" &&
    terraform ${@:3} \
        -var="k8s_context=$1" \
        $backend_arg \
        $var_file
  )
}

function parse_args {
  if [ $# -lt 2 ]; then
    echo "Must specify environment & terraform command"
    exit 1
  fi

  directory="infrastructure"
  context=""

  case $1 in
    "pre-dev")
      context="kind-kind"
      directory="pre_infrastructure"
    ;;
    "pre-prod")
      context="microk8s"
      directory="pre_infrastructure"
    ;;
    "dev")
      context="kind-kind"
      directory="infrastructure"
    ;;
    "prod")
      context="microk8s"
      directory="infrastructure"
    ;;
    *)
      echo "Invalid environment: $2"
      exit 1
    ;;
  esac

  run_for_env "$context" "$directory" ${@:2}
}

parse_args $@