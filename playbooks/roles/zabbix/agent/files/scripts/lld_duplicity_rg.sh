#! /bin/sh
if [ ! -d /var/tmp/duplicity/ ]; then
    echo "ERROR: duplicity is not monitored (/var/tmp/duplicity/ is missing)"
    exit 1
fi
FIRST="yes"
echo '{'
echo '  "data": ['
for p in `ls -1 /var/tmp/duplicity/ | grep status | sed 's/^\(.*\)-status-.*$/\1/' | uniq`; do
	if [ "${FIRST}" = "yes" ]; then
		FIRST="no"
	else
		echo ','
	fi
	echo '    {'
	echo '      "{#PROFILENAME}": "'${p}'"'
	echo -n '    }'
done
echo ''
echo '  ]'
echo '}'
