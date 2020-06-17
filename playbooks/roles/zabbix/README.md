# Agent

[Agent role readme](agent/README.md)

used tag `zabbix-agent` - to run only zabbix agent tasks

# Server

[Server role readme](server/README.md)

used tag `zabbix-server` - to run only zabbix server tasks

---

# RG OpenEdx quick configuration

```
zabbix_enabled: true
rg_support_package: "OnSupport"
```
list of avalaible Support Packages is in ``zabbix_support_conf`` [here](/inventories/edx-defaults/edx-rg-zabbix.yml)

# RG OpenEdx full configuration
```
zabbix_enabled: true
rg_support_package: "OnSupport"
zabbix_force_in_maintenance: true
zabbix_addl_groups:
  - "Custom Group"
zabbix_addl_templates:
  - "Active Template HDD SMART"
  - "Active Template App Docker"
```

# Quick example for non-OpenEdx installation

```
ansible-playbook -i,51.15.146.148 -uraccoon edx-zabbix-single.yml \
    -ezabbix_enabled=true \
    -ezabbix_server_host_dns=51.15.146.148 \
    -ezabbix_server_host_visible_name="'The Custom Project'" \
    -ezabbix_server_host_groups="['Test-Maintenance','Client Prod']" \
    -ezabbix_server_host_link_templates="['Active Template OS Linux','Active Template HDD SMART']"
```

will add to the **instance**:
- all possible RG checks
- "active" zabbix agent with Hostname: "51.15.146.148_ipaddress_of_instance"

will add to **zabbix server** instance with:
- hostname: "51.15.146.148_ipaddress_of_instance"
- visible name: "The Custom Project"
- groups: "Test-Maintenance" and "Client Prod"
- templates: "Active Template OS Linux" and "Active Template HDD SMART"

# Example for OpenEdx without inventory

```
EDXAPP_LMS_BASE=lms.dns.com ; EDXAPP_PLATFORM_NAME="LMS EDX" ; ansible-playbook \
    --vault-password-file=../.vaultpass -i,${EDXAPP_LMS_BASE} -uraccoon \
    -e@inventories/edx-defaults/edx-rg-zabbix.yml \
    -eEDXAPP_LMS_BASE=${EDXAPP_LMS_BASE} \
    -eCOMMON_MYSQL_READ_ONLY_USER=read_only -eCOMMON_MYSQL_READ_ONLY_PASS="password" \
    -eMONGO_ADMIN_USER=admin -eMONGO_ADMIN_PASSWORD="password" -eEDXAPP_MONGO_HOSTS=localhost \
    -eEDXAPP_MYSQL_HOST=localhost -ezabbix_enabled=true -eEDXAPP_PLATFORM_NAME="${EDXAPP_PLATFORM_NAME}" \
    -erg_support_package=OnSupport \
    edx-zabbix-single.yml
```
