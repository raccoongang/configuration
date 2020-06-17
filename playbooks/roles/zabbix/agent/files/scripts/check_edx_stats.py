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

config = ConfigParser.SafeConfigParser( { 'host': host, 'port': str(port), 'user': user, 'password': password, 'database': database } )
if config.read(os.path.dirname(os.path.realpath(__file__)) + '/scripts.cfg'):

    user = config.get('client', 'user')
    password = config.get('client', 'password')
    database = config.get('client', 'database')
    host = config.get('client', 'host')
    port = config.getint('client', 'port')

if host == '127.0.0.1': # special for OpenEdx
    host = 'localhost'

queries = {
    'total_students': 'SELECT COUNT(*) FROM {database}.auth_user'.format(database=database),
    'total_courses': 'SELECT count(*) FROM {database}.course_overviews_courseoverview'.format(database=database),
    'total_open_courses': 'SELECT count(*) FROM {database}.course_overviews_courseoverview WHERE catalog_visibility<>"none" AND enrollment_end>NOW()'.format(database=database),
    'active_students_month': 'SELECT COUNT(*) FROM {database}.auth_user WHERE last_login>DATE_SUB(NOW(),INTERVAL 1 MONTH)'.format(database=database),
    'active_students_week': 'SELECT COUNT(*) FROM {database}.auth_user WHERE last_login>DATE_SUB(NOW(),INTERVAL 1 WEEK)'.format(database=database),
    'course_enrollments': 'SELECT COUNT(*) FROM {database}.student_courseenrollment'.format(database=database),
    'course_enrollments_month': 'SELECT COUNT(*) FROM {database}.student_courseenrollment WHERE created>DATE_SUB(NOW(),INTERVAL 1 MONTH)'.format(database=database),
    'course_enrollments_week': 'SELECT COUNT(*) FROM {database}.student_courseenrollment WHERE created>DATE_SUB(NOW(),INTERVAL 1 WEEK)'.format(database=database),
    'course_completions': 'SELECT IF((SELECT COUNT(*) FROM {database}.grades_persistentcoursegrade WHERE letter_grade="Pass")=0,"NA",(SELECT COUNT(*) FROM {database}.grades_persistentcoursegrade where letter_grade="Pass")) as cntr'.format(database=database),
    'course_completions_month': 'SELECT IF((SELECT COUNT(*) FROM {database}.grades_persistentcoursegrade WHERE letter_grade="Pass" AND passed_timestamp>DATE_SUB(NOW(),INTERVAL 1 MONTH))=0,"NA",(SELECT COUNT(*) FROM {database}.grades_persistentcoursegrade where letter_grade="Pass" AND passed_timestamp>DATE_SUB(NOW(),INTERVAL 1 MONTH))) as cntr'.format(database=database),
    'course_completions_week': 'SELECT IF((SELECT COUNT(*) FROM {database}.grades_persistentcoursegrade WHERE letter_grade="Pass" AND passed_timestamp>DATE_SUB(NOW(),INTERVAL 1 WEEK))=0,"NA",(SELECT COUNT(*) FROM {database}.grades_persistentcoursegrade where letter_grade="Pass" AND passed_timestamp>DATE_SUB(NOW(),INTERVAL 1 WEEK))) as cntr'.format(database=database),
    'generated_certs': 'SELECT COUNT(*) FROM {database}.certificates_generatedcertificate'.format(database=database),
    'generated_certs_month': 'SELECT COUNT(*) FROM {database}.certificates_generatedcertificate WHERE created_date>DATE_SUB(NOW(),INTERVAL 1 MONTH)'.format(database=database),
    'generated_certs_week': 'SELECT COUNT(*) FROM {database}.certificates_generatedcertificate WHERE created_date>DATE_SUB(NOW(),INTERVAL 1 WEEK)'.format(database=database),
}

try:

    client = MySQLdb.connect(host=host, port=port, user=user, passwd=password, connect_timeout=3)
    cursor = client.cursor()

    for metric, query in queries.items():
        cursor.execute(query, None)
        row = cursor.fetchone()
        if row and len(row):
            print "{}: {}".format(metric,row[len(row)-1])
        else:
            print "Failed: No such item ({})".format(metric)

    cursor.close()
    client.close()

except MySQLdb.Error, e:
    print "Failed: MySQL Error [%d]: %s" % (e.args[0], e.args[1])
    exit(255)
