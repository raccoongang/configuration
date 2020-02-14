#!/bin/sh

# please do not compare metrics from CGROUP and 'docker stats'
# there is a trash and headache. containers which has small memory and CPU usage
# shows difference about 200% for memory! that is sucks!
# https://github.com/moby/moby/issues/10824
# https://stackoverflow.com/questions/50865763/memory-usage-discrepancy-cgroup-memory-usage-in-bytes-vs-rss-inside-docker-con
# https://stackoverflow.com/questions/29831501/docker-not-reporting-memory-usage-correctly

# very usefull comments is here
# 1. all output in bytes
# 2. doker developers are dope!
# 3. output will be parsed in zabbix

CACHE_DIR="/tmp/zabbix_docker"
CACHE="${CACHE_DIR}/out"
mkdir -p ${CACHE_DIR} || exit 1
chmod o-wrx ${CACHE_DIR}

CACHE_TS=`ls -l --time-style=+%s /tmp/zabbix_docker/out 2> /dev/null | cut -f 6 -d " "`
NOW=`date +%s`
CACHE_MOD=`expr 0${NOW} - 0${CACHE_TS}`

if test -n "$1" -a -s ${CACHE} -a 0${CACHE_MOD} -le 60 ; then
  grep "name:$1" ${CACHE}
  exit 0
else
  counter=10; while test -s ${CACHE}.new -a 0${counter} -ge 0 ; do sleep 1; counter=`expr ${counter} - 1`; done
  echo "# this file was created by $0" > ${CACHE}.new
fi

DISKS_SIZE=`df -k | grep ^/ | awk 'BEGIN { s=0; } { s+=$2; } END { print s*1024; }'`
CPUS=`cat /proc/cpuinfo | grep ^processor | wc -l`
CLK_TCK=`getconf CLK_TCK`
sysmem=`grep MemTotal /proc/meminfo | awk '{print $2*1024;}'`
# 1000000000 - turn into nanoseconds 1 s = 1e9 ns
# CLK_TCK - man 5 proc
syscpu=`grep ^cpu" " /proc/stat | awk '{ print ($2 + $3 + $4 + $5 + $6 + $7 + $8)*1000000000/'${CLK_TCK}'+1; }'`

docker ps --no-trunc | grep -v "CONTAINER ID" | awk '{ print $1" "$(NF); }' | while read id name ; do

  # memory
  memlimit=`cat /sys/fs/cgroup/memory/docker/${id}/memory.limit_in_bytes`
  # 9999999999 - there is no limits for container memory is set
  if test ${memlimit} -gt 9999999999 ; then memlimit=${sysmem} ; fi
  memused=`cat /sys/fs/cgroup/memory/docker/${id}/memory.usage_in_bytes`
  memfailcnt=`cat /sys/fs/cgroup/memory/docker/${id}/memory.failcnt`
  memused_percent=`echo | awk '{ printf("%3.2f", ('${memused}' / '${memlimit}' * 100));}'`

  # cpu
  cpuusage=`cat /sys/fs/cgroup/cpuacct/docker/${id}/cpuacct.usage`

  syscpu_prev=`cat ${CACHE_DIR}/${name}_syscpu.stat 2> /dev/null`
  cpuusage_prev=`cat ${CACHE_DIR}/${name}_cpuusage.stat 2> /dev/null`
  # need to save current values to calculate metrics to period of time
  # when previuos check happens (not for all the time while system is uptime)
  echo -n ${syscpu} > ${CACHE_DIR}/${name}_syscpu.stat
  echo -n ${cpuusage} > ${CACHE_DIR}/${name}_cpuusage.stat
  syscpu=`expr 0${syscpu} + 0`
  cpuusage=`expr 0${cpuusage} + 0`
  syscpu_prev=`expr 0${syscpu_prev} + 0`
  cpuusage_prev=`expr 0${cpuusage_prev} + 0`
  syscpu_delta=`expr ${syscpu} - ${syscpu_prev}`
  cpuusage_delta=`expr ${cpuusage} - ${cpuusage_prev}`
  # echo "cont: ${cpuusage} sys: ${syscpu}"
  # echo "cont: ${cpuusage_delta} sys: ${syscpu_delta}"
  cpuusage_percent=`echo | awk '{ printf("%3.2f", ('${cpuusage_delta}' / '${syscpu_delta}' * 100) * '${CPUS}');}'`

  # state
  # fuck!
  inspect=`docker inspect -f 'status:{{ .State.Status }}:pid:{{ .State.Pid }}:mounts:{{ .Mounts }}' ${id}`
  echo ${inspect} > /tmp/zabbix_docker/${name}_debug

  status=`echo ${inspect} | cut -f 2 -d :`
  OUT="name:${name} status:${status} memlimit:${memlimit} memused:${memused} memusedpercent:${memused_percent} memfailcnt:${memfailcnt} cpu:${cpuusage_percent}"

  # network
  container_pid=`echo ${inspect} | cut -f 4 -d :`
  OUT=${OUT}" "`grep eth0 /proc/${container_pid}/net/dev | awk '{ printf("netin:"$2" netout:"$10); }'`

  # disk
  # fuck!
  mounts=`echo ${inspect} | cut -f 6 -d : | sed 's|{|\n{|g' | sed 's|^[^/]*\(/[^ ]*\).*$|\1|' | grep ^/`
  if test -z "${mounts}" ; then
    diskusage="0"
    OUT=${OUT}" diskusage:0"
  else
    diskusage=`du -sx ${mounts} | sed 's| |\n|g' | awk 'BEGIN { sum=0; } { s+=($1*1024); } END { printf(s); }'`
    OUT=${OUT}" diskusage:"${diskusage}
  fi

  echo awk '{ printf("%3.2f", '${diskusage}' / '${DISKS_SIZE}' * 100); }' >> /tmp/zabbix_docker/${name}_debug
  OUT=${OUT}" diskusage_percent:"`echo | awk '{ printf("%3.2f", '${diskusage}' / '${DISKS_SIZE}' * 100); }'`

  echo ${OUT} >> ${CACHE}.new
  if test -n "$1" -a "$1" = ${name} ; then
    echo ${OUT}
  fi

done

mv ${CACHE}.new ${CACHE}
if test -z "$1" ; then
  cat ${CACHE}
fi
