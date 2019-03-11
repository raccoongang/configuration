#!/bin/bash

if [ -z "$ANSIBLE_SSH_KEY" ]
then
    echo "ANSIBLE_SSH_KEY env variable is needed to use image."
    echo "By default it's provided by Gitlab CI."
    echo "If you want to use this image locally please provide it yourself"
    exit 1
fi

if [ -z "$ANSIBLE_VAULT_KEY" ]
then
    echo "ANSIBLE_VAULT_KEY env variable is needed to use image."
    echo "By default it's provided by Gitlab CI."
    echo "If you want to use this image locally please provide it yourself"
    exit 1
fi

echo "$ANSIBLE_SSH_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "Loaded SSH key from environment"

echo "$ANSIBLE_VAULT_KEY" > ~/vault_password
chmod 600 ~/vault_password
echo "Loaded Ansible Vault key from environment"

exec "$@"
