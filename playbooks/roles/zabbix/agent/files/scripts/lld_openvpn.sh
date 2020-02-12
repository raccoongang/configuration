#!/bin/bash

echo "{"
echo "\"data\":["

comma=""
for user in `ls -1 /etc/openvpn/keys/clients/ | sed 's/@/_/'`
do
    echo "    $comma{\"{#VPNUSER}\":\"$user\"}"
    comma=","
done

echo "]"
echo "}"
