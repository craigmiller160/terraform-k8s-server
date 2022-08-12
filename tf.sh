#!/bin/bash

dev_nexus_image="klo2k/nexus3:3.29.2-02"
prod_nexus_image="sonatype/nexus3:3.29.2"

function parse_args {
  if [ $# -lt 2 ]; then
    echo "Must specify environment & terraform command"
    exit 1
  fi

  # TODO finish this
  case $1 in
    "phase1"|"phase2"|"phase3") ;;
    *) ;;
  esac
}

parse_args $@