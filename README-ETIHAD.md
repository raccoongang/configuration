Start provision of automated system on local computer
=====================================================

- virtualenv venv
- source venv/bin/activate
- pip install requierements.txt
- change awx hostname in inventory/pre-prod.ini to DNS name assosiated with AutomationVM in Azure
- change awx `ansible_user` to username specified upon Azure deployment of AutomationVM
- change awx `ansible_port` to SSH port configured in Azure Firewall to access AutomationVM
- create SSH key pair or copy existing deployment SSH key pair
```
ssh-keygen -f inventory/pre-prod.id_rsa
```
- deploy public key of SSH pair to AutomationVM user with password-less sudo access rights
```
cat inventory/pre-prod.id_rsa.pub | ssh azureuser@1.2.3.4 -c 'tee -a .ssh/authorized_keys'
```
- cd playbooks
- ansible-playbook -i ../inventory/pre-prod.hosts --ask-vault-pass --private-key=../inventory/pre-prod.id_rsa edx_awx.yml
