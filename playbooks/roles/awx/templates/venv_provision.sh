#!/bin/sh
set -e
yum install -y gcc python-devel mariadb-devel
VENV="/var/lib/awx/projects/venv/ansible-2.5.5"
mkdir -p ${VENV}
virtualenv --python=/usr/bin/python2.7 ${VENV}
. ${VENV}/bin/activate
pip install -r /var/lib/awx/projects/requirements_isolated.txt
pip install -r /var/lib/awx/projects/venv_provision_requirements.txt
rm -rf ~/.cache
yum remove -y gcc python-devel
yum clean all
