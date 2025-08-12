#!/bin/bash

dnf install ansible -y

ansible-pull -i localhost, -U https://github.com/DAWS-82S/expense-ansible-roles-tf.git main.yaml \
  -e COMPONENT=frontend \
  -e ENVIRONMENT=$1 \
  -e BACKEND_HOST=$2
# push
# ansible-playbook -i inventory mysql.yaml

#pull

#ansible-pull  -i localhost, -U https://github.com/DAWS-82S/expense-ansible-roles-tf.git main.yaml -e COMPONENT=frontend -e ENVIRONMENT=$1 