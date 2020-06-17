#! /bin/sh
grep ^free ~jenkins/ansible/deployment/local_config/$1.csv | wc -l
