#! /bin/sh

( for MDIR in /var/mail /var/spool/mail ; do grep "^From " ${MDIR}/* ; done ) 2> /dev/null | wc -l
