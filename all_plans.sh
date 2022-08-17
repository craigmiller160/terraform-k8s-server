#!/bin/bash

# $1 = env, $2 = directory
function get_plan {
  plan=$(./$2/tf.sh $1 plan)
  if [ $? -ne 0 ]; then
    return 1
  fi

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

function stop_if_error {
  if [ $1 -ne 0 ]; then
    exit 1
  fi
}

# $1 = env
function print_plans {
  echo "Getting plans for all modules"

  echo "k8s_custom_resources"
  get_plan $1 "k8s_custom_resources"
  stop_if_error $?

  echo "1Password"
  get_plan $1 "1Password"
  stop_if_error $?

  echo "databases"
  get_plan $1 "databases"
  stop_if_error $?

  echo "nexus_deployment"
  get_plan $1 "nexus_deployment"
  stop_if_error $?

  echo "nexus_config"
  get_plan $1 "nexus_config"
  stop_if_error $?

  echo "ingress"
  get_plan $1 "ingress"
  stop_if_error $?
}

validate_env $1
print_plans $1