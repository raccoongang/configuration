#! /bin/sh

set -e

for DIR in `echo $1 | tr ':' ' '` ; do
  if [ "${DIR}" = "/var/tmp/zabbix_example1" -o "${DIR}" = "/var/tmp/zabbix_example2" ] ; then
    echo "$0: please do not use zabbix_example1 or zabbix_example2 directories" >&2
    exit 1
  elif [ ! -d "${DIR}" ] ; then
    echo "$0: directory ${DIR} not found" >&2
    exit 1
  fi
done

FIRST="yes"
for DIR in `echo $1 | tr ':' ' '` ; do
  for s in `ls -1 ${DIR} | sed 's/^\(.*\)_\w\+$/\1/' | uniq`; do
    if [ "${FIRST}" = "yes" ]; then
      echo '{'
      echo '  "data": ['
      FIRST="no"
    else
      echo ','
    fi
    echo '    {'
    echo '      "{#CUSTOM_SERVICE}": "'${s}'",'
    echo '      "{#CUSTOM_SERVICE_DIR}": "'${DIR}'"'
    echo -n '    }'
  done
done
if [ "${FIRST}" = "no" ]; then
  echo ''
  echo '  ]'
  echo '}'
fi
