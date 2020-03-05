#!/usr/bin/env /etc/zabbix/.venv/bin/python
# -*- coding: utf-8 -*-

import MySQLdb
from sys import argv
import ConfigParser
import os
import time

user = 'root'
password = ''
database = 'edxapp'
host = 'localhost'
port = 3306
touchfile = "/tmp/zabbix_check_edx_loggedinusers_py.touch"

if os.path.exists(touchfile):
   lastcheck = int(os.stat(touchfile).st_mtime)
else:
   lastcheck = time.time() - 600;

if os.path.exists(touchfile):
    os.utime(touchfile, None)
else:
    open(touchfile, 'a').close()

config = ConfigParser.SafeConfigParser( { 'host': host, 'port': str(port), 'user': user, 'password': password, 'database': database } )
if config.read(os.path.dirname(os.path.realpath(__file__)) + '/scripts.cfg'):

    user = config.get('client', 'user')
    password = config.get('client', 'password')
    database = config.get('client', 'database')
    host = config.get('client', 'host')
    port = config.getint('client', 'port')

if host == '127.0.0.1': # special for OpenEdx
    host = 'localhost'

try:
    query = 'SELECT COUNT(*) FROM {database}.auth_user WHERE last_login>FROM_UNIXTIME({lastcheck})'.format(database=database,lastcheck=lastcheck)

    client = MySQLdb.connect(host=host, port=port, user=user, passwd=password, connect_timeout=3)
    cursor = client.cursor()
    cursor.execute(query, None)
    row = cursor.fetchone()
    if row and len(row):
        print row[len(row)-1]
    else:
        print "Failed: No such item ({})".format(item)
    cursor.close()
    client.close()

except MySQLdb.Error, e:
    print "Failed: MySQL Error [%d]: %s" % (e.args[0], e.args[1])
    exit(255)
