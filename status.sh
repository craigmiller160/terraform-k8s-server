#!/bin/bash

output=$(./nexus_deployment/tf.sh dev plan | grep "Plan:")

echo $output