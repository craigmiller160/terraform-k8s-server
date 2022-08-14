#!/bin/bash

function ensure_prod_backup {
  if [ ! -f ~/.kube/config.prod ]; then
    echo "Copying existing config to create prod config backup"
    cp ~/.kube/config ~/.kube/config.prod
  fi
}

function set_dev_config {
  echo "Setting dev config"
  microk8s config > ~/.kube/config
}

function set_prod_config {
  echo "Setting prod config"
  cp ~/.kube/config.prod ~/.kube/config
}

function set_config {
  case $1 in
    "dev") set_dev_config ;;
    "prod") set_prod_config ;;
    *)
      echo "Invalid env: $1"
    ;;
  esac
}

ensure_prod_backup
set_config $1
