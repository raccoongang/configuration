Role to configure duplicity backups
===================================

Required extra vars:
====================

backup_enabled: <True|False>
aws_backup_region: "eu-west-1" # required for regions different from 'ua-east-1'

Custom profiles configuration:
==============================

backup_cron_schedule: "21 10 * * *"
backup_duplicity:
    target: 'target.host.ltd'
    target_method: '<s3|azure|ftp|rsync|ssh>'
    target_user: '<username>'
    target_pass: '<user_password>'
    profiles:
      - name: <backup_name1>
        type: '<file|mysql|mongo|postgres>|...'    # for full list of available profiles see templates/profiles
        <profile_configuration>                    # see templates/profiles/<type>/README.md
      ...

Examples:
=========
backup_enabled: true
backup_duplicity:
    target: 'ftp.example.com'
    target_method: 'ftp'
    target_user: 'ftpuser'
    target_pass: 'secret'
    runas_user: 'root'     # must be root for "profiles[type]: file" to read files with any owner and attr
                           # can be blank (default duplicity user) for other types of backup (for example db dumps)
    profiles:
      - name: home_directory
        type: file
        source: /home/
        exclude:
          - '- **.pyc'
          - '- **.mp3'
          - '- **.avi'

      - name: mysql
        type: mysql
        databases:                         # default: all databases
          - web_database
          - web_admin
        mysql_host: localhost              # default: localhost
        mysql_user: mysqluser
        mysql_password: mysqluserpassword

      - name: mongo
        type: mongo
        databases:                         # default: all databases
          - edxapp
          - cs_comments_service
        mongo_host: localhost
        mongo_user: admin
        mongo_password: mongoadminuserpassword
        mongo_authdb: admin

GPG encryption:
===============

- on local machine execute:
```
gpg --gen-key
gpg --armor --export KEYIDB12A89D52E01191C
gpg --armor --export-secret-key KEYIDB12A89D52E01191C
```
- place output of first export into `backup_gpg_key_pub` variable
- place out of second export into `backup_gpg_key_priv` variable
- configure next variables:
```
backup_gpg_key: "KEYIDB12A89D52E01191C"
backup_gpg_key_sign: "{{ backup_gpg_key }}"
backup_gpg_opts: "--trust-model always"
backup_gpg_pw: PASSWORDUSEDON-gen-key
backup_gpg_key_pub: |
  -----BEGIN PGP PUBLIC KEY BLOCK-----

    mQENBFxMURgBCADLP2h4WAb6Mpt+8Dn8Vf+tih1Z7fyea8sFjpWGOSf8dF9kFSmS
    ...
    ...
backup_gpg_key_priv: |
  -----BEGIN PGP PRIVATE KEY BLOCK-----

    lQPGBFxMURgBCADLP2h4WAb6Mpt+8Dn8Vf+tih1Z7fyea8sFjpWGOSf8dF9kFSmS
    ...
    ...
```
