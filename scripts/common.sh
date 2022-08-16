#!/bin/bash

common_file_dir=$(dirname "${BASH_SOURCE[0]}")

# $1 = env
function get_env {
  case $1 in
    "dev") source "$common_file_dir/../scripts/dev.env" ;;
    "prod") source "$common_file_dir/../scripts/prod.env" ;;
    *)
      echo "Invalid environment: $1"
      exit 1
    ;;
  esac
}

# $1 = Command
function get_backend_context {
  if [ $1 == "init" ]; then
    echo "-backend-config=config_context=$k8s_context"
  else
    echo ""
  fi
}

# $1 = Command
function get_k8s_context_var {
  if [ $1 == "fmt" ]; then
    echo ""
  else
    echo "-var=k8s_context=$k8s_context"
  fi
}

# $1 = Directory, $2 Command
function get_secrets_file {
  if [ $2 == "fmt" ]; then
    echo ""
  elif [ -f "$1/secrets.tfvars" ]; then
    echo "-var-file=secrets.tfvars"
  else
    echo ""
  fi
}

# $1 = Command
function get_nexus_image_var {
  if [ $1 == "fmt" ]; then
    echo ""
  else
    echo "-var=nexus_image=$nexus_image"
  fi
}

# $1 = Command
function get_nexus_host_var {
  if [ $1 == "fmt" ]; then
    echo ""
  else
    echo "-var=nexus_host=$nexus_host"
  fi
}