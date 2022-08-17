#!/bin/bash

# TODO what if uninitialized or other error?

# $1 = env, $2 = directory
function get_plan {
  plan=$(./$2/tf.sh $1 plan)
  output=$(echo "$plan" | grep "Plan:")
  if [ ${#output} -gt 0 ]; then
    echo "  $output"
  fi
}

# $1 = env
function validate_env {
  case $1 in
    "dev"|"prod") ;;
    *)
      echo "Invalid environment: $1"
      exit 1
    ;;
  esac
}

# $1 = env
function print_plans {
  echo "Getting plans for all modules"

  echo "k8s_custom_resources"
  get_plan $1 "k8s_custom_resources"

  echo "1Password"
  get_plan $1 "1Password"

  echo "databases"
  get_plan $1 "databases"

  echo "nexus_deployment"
  get_plan $1 "nexus_deployment"

  echo "nexus_config"
  get_plan $1 "nexus_config"

  echo "ingress"
  get_plan $1 "ingress"
}

validate_env $1
print_plans $1