#!/usr/bin/env bash

if ! test -x /edx/bin/python.discovery -o -x /edx/bin/python.edxapp ; then
  # for multi-instance installations: do nothing on non edxapp instances
  exit
fi

SHELL=/bin/bash
COURSE_DISCOVERY_CFG=/edx/etc/discovery.yml
LOG_FILE=/edx/var/log/update_discovery/edx.log
mkdir -p `dirname ${LOG_FILE}`
exec &>> ${LOG_FILE}
exec 2>&1
export SHELL
export COURSE_DISCOVERY_CFG

if test -x /edx/bin/python.discovery ; then
  sudo -Eu discovery /edx/app/discovery/venvs/discovery/bin/python /edx/app/discovery/discovery/manage.py refresh_course_metadata --settings=course_discovery.settings.production
  sudo -Eu discovery /edx/app/discovery/venvs/discovery/bin/python /edx/app/discovery/discovery/manage.py update_index --disable-change-limit --settings=course_discovery.settings.production
  sudo -Eu discovery /edx/app/discovery/venvs/discovery/bin/python /edx/app/discovery/discovery/manage.py remove_unused_indexes --settings=course_discovery.settings.production
else
  echo "discovery service not found" >&2
fi
if test -x /edx/bin/python.edxapp ; then
  # random delay for multi-instance installations, where multiple instances runs this task simultaneously
  RAND=`head -c 1 /dev/urandom | od -t u1 | cut -c9-`
  sleep `expr ${RAND} % 90 + 1`

  sudo -Eu www-data /edx/bin/python.edxapp /edx/bin/manage.edxapp lms cache_programs --settings=aws
else
  echo "edxapp service not found" >&2
fi
