#!/bin/sh
PATH=/usr/sbin:/sbin:${PATH}
if [ "$1" = "status" ]; then
        ST=`timeout 10 rabbitmqctl status 2>&1`
        if echo "${ST}" | grep -q alarms ; then
            echo "${ST}" | grep "alarms,\[\]" | wc -l
        else
            echo "${ST}" | grep "uptime" | wc -l
        fi
        exit
fi

rabbitmqctl $*
