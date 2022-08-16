#!/bin/bash

module_file_dir=$(dirname "${BASH_SOURCE[0]}")

source "$module_file_dir/../scripts/common.sh"

# $1 = env, $2 = Command
get_env $1
backend_arg=$(get_backend_context $2)
k8s_context_var=$(get_k8s_context_var $2)


(
  cd "$module_file_dir" &&
  terraform ${@:2} \
    $backend_arg \
    $k8s_context_var
)