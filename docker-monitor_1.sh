#!/bin/bash

export SYSTEM_DIR=/dev/shm/docker-monitor
export CONTAINER_DIR=${SYSTEM_DIR}/container
export SYSTEM_STATS=${SYSTEM_DIR}/system
export TEMP_DIR=${SYSTEM_DIR}/temp

export DIR_INSTALL_DOCKER_MONITOR=/srv/docker-monitor
SLEEP_TIME=5

mkdir -p ${SYSTEM_DIR}
mkdir -p ${SYSTEM_STATS}
mkdir -p ${CONTAINER_DIR}
mkdir -p ${TEMP_DIR}
chmod 777 ${TEMP_DIR}

nohup ${DIR_INSTALL_DOCKER_MONITOR}/docker-monitor_2.sh & 

while true
do
	ls -l ${CONTAINER_DIR} | grep ^drwxr | awk '{print $9}' > ${TEMP_DIR}/containers.txt
	while read cntner
	do
		curl -XGET -s --unix-socket /var/run/docker.sock http:/v1.4/containers/${cntner}/stats?stream=false > ${TEMP_DIR}/cntner.stats
		cat ${TEMP_DIR}/cntner.stats > ${CONTAINER_DIR}/${cntner}/cntner.stats


		cat ${CONTAINER_DIR}/${cntner}/cntner.stats | jq .cpu_stats.system_cpu_usage > ${CONTAINER_DIR}/${cntner}/cpu/system_cpu_usage
		


	done < ${TEMP_DIR}/containers.txt

   	sleep ${SLEEP_TIME}
	ls -l ${CONTAINER_DIR} | grep ^drwxr | awk '{print $9}' > ${TEMP_DIR}/containers.txt
done
