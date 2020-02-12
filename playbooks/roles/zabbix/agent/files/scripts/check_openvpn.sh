#! /bin/sh

CMD="$1"
ARG=`echo $2 | tr "_" "."`

if [ "${CMD}" = "user_status" -a "${ARG}" != "" ]; then
	grep ^${ARG}, /var/log/openvpn/*-status.log | wc -l

elif [ "${CMD}" = "num_user" ]; then
	ls -1 /etc/openvpn/keys/clients/ | wc -l

elif [ "${CMD}" = "num_users_online" ]; then
	cat /var/log/openvpn/*-status.log | grep -c '^.*,.*,.*,.*,.*:..:'

elif [ "${CMD}" = "user_byte_received" -a "${ARG}" != "" ]; then
	if grep -q ${ARG}, /var/log/openvpn/*-status.log ; then
		grep ^${ARG}, /var/log/openvpn/*-status.log | tr "," "\n" | sed -n '3p'
	else
		echo "0"
	fi

elif [ "${CMD}" = "user_byte_sent" -a "${ARG}" != "" ]; then
	if grep -q ${ARG}, /var/log/openvpn/*-status.log ; then
		grep ^${ARG}, /var/log/openvpn/*-status.log | tr "," "\n" | sed -n '4p'
	else
		echo "0"
	fi

else
	echo "$0: unknown argument or wrong number of arguments" >&2
	exit 1
fi
