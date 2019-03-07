#!/bin/sh

service_state=`timeout 5s sudo -S /edx/bin/supervisorctl status | grep -w "$1" | awk '{print $2}'`
if [ "$service_state" = "RUNNING" ]
then
        echo "1"
elif [ -z "$service_state" ]
then
	echo "not supported"
else
        echo "0"
fi
