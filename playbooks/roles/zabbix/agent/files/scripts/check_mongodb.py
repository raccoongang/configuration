#!/usr/bin/env /etc/zabbix/.venv/bin/python
# -*- coding: utf-8 -*-

from pymongo import MongoClient,errors
from sys import argv
import ConfigParser
import os

user = 'admin'
password = ''
database = 'test'
host = '127.0.0.1'
port = 27017
replica_name = ''
use_ssl = False

config = ConfigParser.SafeConfigParser( { 'host': host, 'port': str(port), 'user': user, 'password': password, 'database': database, 'replica_name': replica_name, 'use_ssl': use_ssl} )
if config.read(os.path.dirname(os.path.realpath(__file__)) + '/scripts.cfg'):

    user = config.get('mongo', 'user')
    password = config.get('mongo', 'password')
    database = config.get('mongo', 'database')
    host = config.get('mongo', 'host')
    port = config.getint('mongo', 'port')
    replica_name = config.get('mongo', 'replica_name')
    use_ssl = config.getboolean('mongo', 'use_ssl')


def responder(array,item):

    try:
        if replica_name:
            client = MongoClient(host, port, ssl=use_ssl, replicaSet=replica_name)
        else:
            client = MongoClient(host, port, ssl=use_ssl)
        db = client[database]
        db.authenticate(user, password)
        assert isinstance(db, object)
        responder_array = db.command("serverStatus")[str(array)]
        return(responder_array[str(item)])
        MongoClient.close()
    except errors.ConnectionFailure, e:
        print("Failed connect to server. Refused.\n")
        exit(255)
    except errors.NetworkTimeout, e:
        print("Failet connect to server. Timeout.\n")
        exit(255)

if len(argv) == 3:
    print(responder(str(argv[1]),str(argv[2])))
else:
    print("Two arguments required. Usage: "+str(argv[0])+" [metric group] [metric]")
    exit(1)
