#!/bin/bash

set -ex  # exit on error, print commands

echo "Running frontend.sh with ENV=$1 and BACKEND_IP=$2"

dnf install ansible -y

ansible-pull -i localhost, -U https://github.com/DAWS-82S/expense-ansible-roles-tf.git main.yaml \
  -e COMPONENT=frontend \
  -e ENVIRONMENT=$1 \
  -e BACKEND_HOST=$2   # <-- add this line!
