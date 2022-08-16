#!/bin/bash

file_dir=$(dirname "${BASH_SOURCE[0]}")

# $1 = env
function get_env {
  case $1 in
    "dev") source "$file_dir/../scripts/dev.env" ;;
    "prod") source "$file_dir/../scripts/prod.env" ;;
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