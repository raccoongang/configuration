# Role creates monitored host on Zabbix server

this is clear role without any connections to OpenEdx installation.

## OpenEdx configuration is prepared in special way by [edx-zabbix-single.yml](../../edx-zabbix-single.yml) task

All required variables is picked from OpenEdx inventory. For more details see edx-zabbix-single.yml file in awx-deployment repisitory.

## Required variables:

zabbix_server_url - default is https://zabbix.raccoongang.com
zabbix_server_user
zabbix_server_password
zabbix_server_host_name - default is `ansible.inventory_hostname`

zabbix_server_host_groups - default is "Test-Maintenance"
zabbix_server_host_link_templates:
  - "Active Template OS Linux"

available templates:

- Active Template App BigBlueButton
- Active Template App Docker
- Active Template App EDX
- Active Template App Elasticsearch cluster
- Active Template App Elasticsearch node
- Active Template App Memcached
- Active Template App MongoDB
- Active Template App MySQL
- Active Template App RabbitMQ
- Active Template App Zabbix Agent
- Active Template Duplicity Status
- Active Template HDD SMART
- Active Template Linux Disk Performance
- Active Template MD Soft RAID
- Active Template OS Linux
- Active Template Sentry Integration
- Active Template Sockets
- Active Template VPN
- Nginx connections
- Template App FTP Service
- Template App HTTP Service
- Template App HTTPS Service
- Template App IMAP Service
- Template App LDAP Service
- Template App MySQL
- Template App NNTP Service
- Template App NTP Service
- Template App POP Service
- Template App SMTP Service
- Template App SSH Service
- Template App Telnet Service
- Template App Zabbix Agent
- Template App Zabbix Proxy
- Template App Zabbix Server
- Template ICMP Ping
- Template Linux Disk Performance
- Template MD Soft RAID
- Template New Relic
- Template OS Linux

