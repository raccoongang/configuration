#!/bin/sh

STATUS_FILE="${1}/${2}_${3}"

if test -f ${STATUS_FILE} ; then
  cat ${STATUS_FILE}
fi
