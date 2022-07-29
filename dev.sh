#!/bin/sh

terraform $@ -var="k8s_context=kind"