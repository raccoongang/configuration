#!/usr/bin/env /etc/zabbix/.venv/bin/python
# -*- coding: utf-8 -*-

import MySQLdb
from sys import argv
import ConfigParser
import os

user = 'root'
password = ''
database = 'mysql'
host = 'localhost'
port = 3306

config = ConfigParser.SafeConfigParser( { 'host': host, 'port': str(port), 'user': user, 'password': password, 'database': database } )
if config.read(os.path.dirname(os.path.realpath(__file__)) + '/scripts.cfg'):

    user = config.get('client', 'user')
    password = config.get('client', 'password')
    database = config.get('client', 'database')
    host = config.get('client', 'host')
    port = config.getint('client', 'port')

if host == '127.0.0.1': # special for OpenEdx
    host = 'localhost'

def responder(item):

    try:
        if(item == 'Version'):
            query = 'SELECT VERSION()'
        else:
            query = 'SHOW GLOBAL STATUS WHERE Variable_name="{}"'.format(item)

        client = MySQLdb.connect(host=host, port=port, user=user, passwd=password, connect_timeout=3)
        cursor = client.cursor()
        cursor.execute(query, None)
        row = cursor.fetchone()
        if row and len(row):
            ret = row[len(row)-1]
        else:
            ret = "Failed: No such item ({})".format(item)
        cursor.close()
        client.close()

    except MySQLdb.Error, e:
        print "Failed: MySQL Error [%d]: %s" % (e.args[0], e.args[1])
        exit(255)

    return ret

if len(argv) == 2:
    print(responder(str(argv[1])))
else:
    print("Usage: "+str(argv[0])+" [metric]")
    exit(1)
