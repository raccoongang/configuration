#!/usr/bin/env bash

#
# Script for installing Ansible and edX configuration and edx-platform repo's

set -xe

if [[ -z "${ANSIBLE_REPO}" ]]; then
  ANSIBLE_REPO="https://github.com/raccoongang/ansible.git"
fi

if [[ -z "${ANSIBLE_VERSION}" ]]; then
  ANSIBLE_VERSION="ficus-rg"
fi

if [[ -z "${CONFIGURATION_REPO}" ]]; then
  CONFIGURATION_REPO="https://github.com/raccoongang/configuration.git"
fi

if [[ -z "${CONFIGURATION_VERSION}" ]]; then
  CONFIGURATION_VERSION="ficus-rg"
fi

if [[ -z "${UPGRADE_OS}" ]]; then
  UPGRADE_OS=false
fi

if [[ -z "${RUN_ANSIBLE}" ]]; then
  RUN_ANSIBLE=true
fi

if [[ -z "${PLATFORM_REPO}" ]]; then
  PLATFORM_REPO="https://github.com/raccoongang/edx-platform.git"
fi

if [[ -z "${PLATFORM_VERSION}" ]]; then
  PLATFORM_VERSION="ficus-rg"
fi

if [[ -z "${MICROSERVICES_VERSION}" ]]; then
  MICROSERVICES_VERSION="open-release/ficus.3"
fi

#
# Bootstrapping constants
#
VIRTUAL_ENV_VERSION="15.0.2"
PIP_VERSION="8.1.2"
SETUPTOOLS_VERSION="24.0.3"
VIRTUAL_ENV="/tmp/bootstrap"
PYTHON_BIN="${VIRTUAL_ENV}/bin"
ANSIBLE_DIR="/tmp/ansible"
CONFIGURATION_DIR="/tmp/configuration"
EDX_PPA="deb http://ppa.edx.org precise main"
EDX_PPA_KEY_SERVER="keyserver.ubuntu.com"
EDX_PPA_KEY_ID="B41E5E3969464050"

cat << EOF
******************************************************************************

Running the edx_ansible bootstrap script with the following arguments:

ANSIBLE_REPO="${ANSIBLE_REPO}"
ANSIBLE_VERSION="${ANSIBLE_VERSION}"
CONFIGURATION_REPO="${CONFIGURATION_REPO}"
CONFIGURATION_VERSION="${CONFIGURATION_VERSION}"

******************************************************************************
EOF


if [[ $(id -u) -ne 0 ]] ;then
    echo "Please run as root";
    exit 1;
fi

if grep -q 'Precise Pangolin' /etc/os-release
then
    SHORT_DIST="precise"
elif grep -q 'Trusty Tahr' /etc/os-release
then
    SHORT_DIST="trusty"
elif grep -q 'Xenial Xerus' /etc/os-release
then
    SHORT_DIST="xenial"
else
    cat << EOF

    This script is only known to work on Ubuntu Precise, Trusty and Xenial,
    exiting.  If you are interested in helping make installation possible
    on other platforms, let us know.

EOF
   exit 1;
fi

EDX_PPA="deb http://ppa.edx.org ${SHORT_DIST} main"

# Upgrade the OS
apt-get update -y
apt-key update -y

if [ "${UPGRADE_OS}" = true ]; then
    echo "Upgrading the OS..."
    apt-get upgrade -y
fi

# Required for add-apt-repository
apt-get install -y software-properties-common python-software-properties

# Add git PPA
add-apt-repository -y ppa:git-core/ppa

# For older software we need to install our own PPA.
apt-key adv --keyserver "${EDX_PPA_KEY_SERVER}" --recv-keys "${EDX_PPA_KEY_ID}"
add-apt-repository -y "${EDX_PPA}"

# Install python 2.7 latest, git and other common requirements
# NOTE: This will install the latest version of python 2.7 and
# which may differ from what is pinned in virtualenvironments
apt-get update -y

apt-get install -y python2.7 python2.7-dev python-pip python-apt python-yaml python-jinja2 build-essential sudo git-core libmysqlclient-dev libffi-dev libssl-dev


# Workaround for a 16.04 bug, need to upgrade to latest and then
# potentially downgrade to the preferred version.
if [[ "xenial" = "${SHORT_DIST}" ]]; then
    #apt-get install -y python2.7 python2.7-dev python-pip python-apt python-yaml python-jinja2
    pip install --upgrade pip
    pip install --upgrade pip=="${PIP_VERSION}"
    #apt-get install -y build-essential sudo git-core libmysqlclient-dev
else
    #apt-get install -y python2.7 python2.7-dev python-pip python-apt python-yaml python-jinja2 build-essential sudo git-core libmysqlclient-dev
    pip install --upgrade pip=="${PIP_VERSION}"
fi

# pip moves to /usr/local/bin when upgraded
PATH=/usr/local/bin:${PATH}
pip install setuptools=="${SETUPTOOLS_VERSION}"
pip install virtualenv=="${VIRTUAL_ENV_VERSION}"


if [[ "true" == "${RUN_ANSIBLE}" ]]; then
    # create a new virtual env
    /usr/local/bin/virtualenv "${VIRTUAL_ENV}"

    PATH="${PYTHON_BIN}":${PATH}

    # Install the configuration repository to install
    # edx_ansible role
    git clone ${CONFIGURATION_REPO} ${CONFIGURATION_DIR}
    cd ${CONFIGURATION_DIR}
    git checkout ${CONFIGURATION_VERSION}
    make requirements

    cd "${CONFIGURATION_DIR}"/playbooks/edx-east
    "${PYTHON_BIN}"/ansible-playbook edx_ansible.yml -i '127.0.0.1,' -c local -e "configuration_version=${CONFIGURATION_VERSION}" -e "edx_ansible_source_repo=${CONFIGURATION_REPO}"

    sudo apt-get install -y python-software-properties
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test

    sudo apt-get update -y
    sudo apt-get upgrade -y

    sudo apt-get install -y build-essential software-properties-common curl git-core libxml2-dev libxslt1-dev python-pip libmysqlclient-dev python-apt python-dev libxmlsec1-dev libfreetype6-dev swig gcc g++
    sudo pip install --upgrade pip==8.1.2
    sudo pip install --upgrade setuptools==24.0.3
    sudo -H pip install --upgrade virtualenv==15.0.2

    cd /edx/app/edx_ansible/edx_ansible/playbooks


    eval "sudo -E /edx/app/edx_ansible/venvs/edx_ansible/bin/ansible-playbook -c local ./edx_sandbox.yml -i "localhost," \
    -e 'forum_version: ${MICROSERVICES_VERSION}' \
    -e 'xqueue_version: ${MICROSERVICES_VERSION}' \
    -e 'notifier_version: ${MICROSERVICES_VERSION}' \
    -e 'certs_version: ${MICROSERVICES_VERSION}' \
    -e 'demo_version: ${MICROSERVICES_VERSION}' \
    -e 'edx_platform_repo: ${PLATFORM_REPO}' \
    -e 'edx_platform_version: ${PLATFORM_VERSION}'"

    eval "/edx/app/edx_ansible/venvs/edx_ansible/bin/ansible-playbook -c local -i 'localhost,' /edx/app/edx_ansible/edx_ansible/playbooks/run_role.yml -e 'role=rabbitmq' -e 'rabbitmq_ip=127.0.0.1'"

    eval "sudo /edx/app/edx_ansible/update edx-platform ${ANSIBLE_VERSION}"

    eval "sudo /edx/bin/supervisorctl restart all"

    # cleanup
    rm -rf "${ANSIBLE_DIR}"
    rm -rf "${CONFIGURATION_DIR}"
    rm -rf "${VIRTUAL_ENV}"
    rm -rf "${HOME}/.ansible"

    cat << EOF
    ******************************************************************************

    Done bootstrapping, edx_ansible is now installed in /edx/app/edx_ansible.
    Time to run some plays.  Activate the virtual env with

    > . /edx/app/edx_ansible/venvs/edx_ansible/bin/activate

    Done OpenEdx installation, edx-platform is now installed in /edx/app/edxapp.
    Activate the virtual env with

    > . /edx/app/edxapp/venvs/edxapp/bin/activate

    ******************************************************************************
EOF
else
    mkdir -p /edx/ansible/facts.d
    echo '{ "ansible_bootstrap_run": true }' > /edx/ansible/facts.d/ansible_bootstrap.json
fi


