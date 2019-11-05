Start provision of automated system
===================================

on local computer prepare python virtualenv with ansible installed
and run provision task to install [Ansible Tower AWX](https://www.ansible.com/products/awx-project) to AutomationVM.
AutomationVM must be provisioned on cloud account within network with access to
FrontendVM, AppVM and BackentVM and accessible via SSH and HTTP/HTTPS from local computer
(ogranizational management network).

Prepare python virtualenv with required modules
-----------------------------------------------

- git clone https://github.com/raccoongang/configuration.git -b etihad-ficus configuration
- cd configuration
- virtualenv venv
- source venv/bin/activate
- pip install requirements.txt

Prepare ansible inventory for AutomationVM
------------------------------------------

- change awx `hostname` in inventory/pre-prod.ini to DNS name assosiated with AutomationVM in Azure
- change awx `ansible_user` to username specified upon Azure deployment of AutomationVM
- change awx `ansible_port` to SSH port configured in Azure Firewall to access AutomationVM
- create new SSH key pair or copy existing deployment SSH key pair
```
ssh-keygen -f inventory/pre-prod.id_rsa
```
- deploy public key of SSH pair to AutomationVM user with password-less sudo access rights
```
cat inventory/pre-prod.id_rsa.pub | ssh azureuser@1.2.3.4 -c 'tee -a .ssh/authorized_keys'
```

Run Ansible Tower AWX provision task
------------------------------------

- source venv/bin/activate
- cd playbooks
- ansible-playbook -i ../inventory/pre-prod.hosts --ask-vault-pass --private-key=../inventory/pre-prod.id_rsa edx_awx.yml

Using AWX
---------

- in brower open URL specified as `hostname` for awx host in inventory/pre-prod.ini
- authorize with credentials specified in `awx.yml`
- run `01 PRE-PROD update all instances` task to install Open edX
