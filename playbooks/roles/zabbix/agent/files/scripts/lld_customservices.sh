#! /bin/sh

set -e

# return empty LLD json when {$CUSTOM_SERVICES_STATUS_DIRS}
# zabbix macro defined as empty string to allow to disable
# checks and alerts
if [ -z "$1" ] ; then
  cat << EOF
{
  "data": [
  ]
}
EOF
  exit
fi

FIRST="yes"
for DIR in `echo $1 | tr ':' ' '` ; do
  # check directory existence and
  # group CUSTOM_SERVICE_lastrun CUSTOM_SERVICE_code CUSTOM_SERVICE_error
  # files by CUSTOM_SERVICE value
  for service in `(test -d ${DIR} && ls -1 ${DIR} 2> /dev/null || echo "DIR-NOT-FOUND-${DIR}/") | sed 's/^\(.*\)_\w\+$/\1/' | uniq`; do
    if [ "${FIRST}" = "yes" ]; then
      echo '{'
      echo '  "data": ['
      FIRST="no"
    else
      echo ','
    fi
    echo '    {'
    echo '      "{#CUSTOM_SERVICE}": "'${service}'",'
    echo '      "{#CUSTOM_SERVICE_DIR}": "'${DIR}'"'
    echo -n '    }'
  done
done
if [ "${FIRST}" = "no" ]; then
  echo ''
  echo '  ]'
  echo '}'
fi
