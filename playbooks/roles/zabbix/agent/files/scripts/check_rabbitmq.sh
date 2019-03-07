#!/bin/sh

if [ "$1" = "status" ]; then
        ST=`timeout 5 rabbitmqctl status`
        if echo "${ST}" | grep -q alarms ; then
            echo "${ST}" | grep "alarms,\[\]" | wc -l
        else
            echo "${ST}" | grep "uptime" | wc -l
        fi
        exit
fi

rabbitmqctl $*
