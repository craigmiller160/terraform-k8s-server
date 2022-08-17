#!/bin/bash

# $1 = env, $2 = directory
function get_plan {
  output=$("./$2/tf.sh" $1 plan | grep "Plan:")
  echo "  $output"
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
}

validate_env $1
print_plans $1