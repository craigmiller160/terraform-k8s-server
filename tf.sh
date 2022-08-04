#!/bin/bash

function run_for_env {

}

function parse_args {
  if [ $# -lt 1 ]; then
    echo "Must specify environment"
    exit 1
  fi

  directory="infrastructure"
  context=""

  case $1 in
    "dev") context="kind-kind" ;;
    "prod") context="microk8s" ;;
    "*")
      echo "Invalid environment"
      exit 1
    ;;
  esac

  if [ $2 != "" ]; then
    case $2 in
      "--pre") directory="pre_infrastructure" ;;
      "*")
        echo "Invalid argument: $2"
        exit 1
      ;;
    esac
  fi

  run_for_env "$context" "$directory"
}

parse_args $@