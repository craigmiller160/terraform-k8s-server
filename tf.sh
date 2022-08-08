#!/bin/bash

dev_nexus_image="klo2k/nexus3:3.29.2-02"
prod_nexus_image="sonatype/nexus3:3.29.2"

function run_for_env {
  backend_arg=""
  var_file=""

  if [ $4 == "init" ]; then
    backend_arg="-backend-config=config_context=$1"
  fi

  if [ -f "$2/secrets.tfvars" ]; then
    var_file="-var-file=secrets.tfvars"
  fi

  (
    cd "$2" &&
    terraform ${@:4} \
        -var="k8s_context=$1" \
        -var="nexus_image=$3" \
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
  nexus_image=""

  case $1 in
    "pre-dev")
      context="kind-kind"
      directory="pre_infrastructure"
      nexus_image=$dev_nexus_image
    ;;
    "pre-prod")
      context="microk8s"
      directory="pre_infrastructure"
      nexus_image=$prod_nexus_image
    ;;
    "dev")
      context="kind-kind"
      directory="infrastructure"
      nexus_image=$dev_nexus_image
    ;;
    "prod")
      context="microk8s"
      directory="infrastructure"
      nexus_image=$prod_nexus_image
    ;;
    *)
      echo "Invalid environment: $2"
      exit 1
    ;;
  esac

  run_for_env "$context" "$directory" "$nexus_image" ${@:2}
}

parse_args $@