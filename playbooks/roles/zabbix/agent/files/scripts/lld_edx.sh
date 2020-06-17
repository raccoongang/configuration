#! /bin/sh

FIRST="yes"
echo '{'
echo '  "data": ['
for s in `timeout 10s sudo -S /edx/bin/supervisorctl status | cut -f 1 -d " "`; do
	if [ "${FIRST}" = "yes" ]; then
		FIRST="no"
	else
		echo ','
	fi
	echo '    {'
	echo '      "{#EDX_SERVICE}": "'${s}'"'
	echo -n '    }'
done
echo ''
echo '  ]'
echo '}'
