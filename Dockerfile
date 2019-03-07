FROM python:3

RUN pip install ansible

ADD playbooks /etc/ansible
