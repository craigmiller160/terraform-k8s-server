#!/bin/sh

terraform $1 -var="k8s_context=kind"