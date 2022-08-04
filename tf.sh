#!/bin/bash

function run_for_env {
  backend_arg=""
  if [ $1 == "init" ]; then
    backend_arg="-backend-config='config_context=$2'"
  fi

  (
    cd "$2" &&
    terraform $1 \
        -var="k8s_context=$2" \
        $backend_arg
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
    "*")
      echo "Invalid environment"
      exit 1
    ;;
  esac

  if [ $1 != "" ]; then
    case $2 in
      "--pre") directory="pre_infrastructure" ;;
      "*")
        echo "Invalid argument: $2"
        exit 1
      ;;
    esac
  fi

  run_for_env "$1" "$context" "$directory"
}

parse_args $@