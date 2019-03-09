FROM python:3

RUN pip install ansible

RUN adduser --system --home /home/ansible --disabled-password  --group ansible

USER ansible
WORKDIR /home/ansible

RUN mkdir .ssh

COPY --chown=ansible bootstrap.sh .

COPY --chown=ansible playbooks /home/ansible

ENV ANSIBLE_ROLES_PATH /home/ansible/roles

ENTRYPOINT ["./bootstrap.sh"]
