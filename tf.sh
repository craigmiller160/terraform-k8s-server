#!/bin/bash

directory=""
env=""

#function run_for_env {
#
#}

function parse_args {
  if [ $# -lt 1 ]; then
    echo "Must specify environment"
    exit 1
  fi

  env="$1"

  if [ $2 != "" ]; then
    case $2 in
      "--pre") directory="pre_infrastructure" ;;
      "*")
        echo "Invalid argument: $2"
        exit 1
      ;;
    esac
  fi
}

parse_args $@