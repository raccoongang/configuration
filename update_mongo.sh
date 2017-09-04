#!/bin/bash

CONFIGURATION_VENV_BIN_PATH='/edx/app/edx_ansible/venvs/edx_ansible/bin'
CONFIGURATION_REPO_PATH='/edx/app/edx_ansible/edx_ansible'
SERVER_VARS='/edx/app/edx_ansible/server-vars.yml'
HOSTS_FILE='/edx/app/edx_ansible/hosts'

$CONFIGURATION_VENV_BIN_PATH/ansible-playbook -i $HOSTS_FILE -e@$SERVER_VARS $CONFIGURATION_REPO_PATH/playbooks/edx-update-mongo.yml

