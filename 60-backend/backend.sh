#!/bin/bash

dnf install ansible -y
# push
# ansible-playbook -i inventory mysql.yaml

#pull
ansible-pull  -i localhost, -U https://github.com/skype755/expense-ansible-roles-tf.git main.yaml -e COMPONENT=backend -e ENVIRONMENT=$1