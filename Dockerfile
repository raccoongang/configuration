FROM python:2

RUN pip install ansible

RUN adduser --system --home /home/ansible --disabled-password  --group ansible

USER ansible
WORKDIR /home/ansible

RUN mkdir .ssh

COPY --chown=ansible bootstrap.sh .

COPY --chown=ansible playbooks /home/ansible/playbooks
COPY --chown=ansible vault /home/ansible/vault

ENV ANSIBLE_ROLES_PATH=/home/ansible/playbooks/roles \
    ANSIBLE_VAULT_PASSWORD_FILE=/home/ansible/vault_password

ENTRYPOINT ["./bootstrap.sh"]
