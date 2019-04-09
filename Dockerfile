FROM python:2

RUN pip install ansible

RUN adduser --system --home /home/ansible --disabled-password  --group ansible

USER ansible
WORKDIR /home/ansible

RUN mkdir .ssh

COPY --chown=ansible bootstrap.sh .

COPY --chown=ansible playbooks /home/ansible/playbooks
COPY --chown=ansible vault /home/ansible/vault
COPY --chown=ansible inventory/ /home/ansible/inventory

ENV ANSIBLE_ROLES_PATH=/home/ansible/playbooks/roles \
    ANSIBLE_CONFIG=/home/ansible/playbooks/ansible.cfg \
    ANSIBLE_VAULT_PASSWORD_FILE=/home/ansible/vault_password \
    ANSIBLE_RETRY_FILES_SAVE_PATH=/tmp \
    ANSIBLE_LIBRARY=/home/ansible/playbooks/library \
    ANSIBLE_INVENTORY=/home/ansible/inventory/hosts.yml,./hosts.yml

ENTRYPOINT ["./bootstrap.sh"]
