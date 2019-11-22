#!/bin/bash

SYSTEM_DIR=/dev/shm/docker-monitor

CONTAINER_DIR=${SYSTEM_DIR}/container
SYSTEM_STATS=${SYSTEM_DIR}/system
TEMP_DIR=${SYSTEM_DIR}/temp
SLEEP_TIME=5

mkdir -p ${SYSTEM_DIR}
mkdir -p ${SYSTEM_STATS}
mkdir -p ${TEMP_DIR}

while true
do
	ls -l ${CONTAINER_DIR} | grep ^drwxr | awk '{print $9}' > ${TEMP_DIR}/containers.txt
	while read cntner
	do	
		echo ${cntner}
		if [ ! -d ${cntner}/memory ]
		then
			mkdir -p ${CONTAINER_DIR}/${cntner}
			mkdir -p ${CONTAINER_DIR}/${cntner}/memory
			mkdir -p ${CONTAINER_DIR}/${cntner}/cpu
			mkdir -p ${CONTAINER_DIR}/${cntner}/network
		fi

		curl -XGET -s --unix-socket /var/run/docker.sock http:/v1.4/containers/${cntner}/stats?stream=false > ${TEMP_DIR}/cntner.stats
		cat ${TEMP_DIR}/cntner.stats > ${CONTAINER_DIR}/${cntner}/cntner.stats

		# Memory Statistics
		cat ${CONTAINER_DIR}/${cntner}/cntner.stats | jq .memory_stats.total_rss > ${CONTAINER_DIR}/${cntner}/memory/total_rss
		cat ${CONTAINER_DIR}/${cntner}/cntner.stats | jq .memory_stats.max_usage> ${CONTAINER_DIR}/${cntner}/memory/max_usage
		cat ${CONTAINER_DIR}/${cntner}/cntner.stats | jq .memory_stats.limit > ${CONTAINER_DIR}/${cntner}/memory/limit
		
		# CPU Statistics
		previous_total_usage=$(cat ${CONTAINER_DIR}/${cntner}/cpu/cpu_usage.total_usage)
		# Uso de CPU por parte do container
		cat ${CONTAINER_DIR}/${cntner}/cntner.stats | jq .cpu_stats.cpu_usage.total_usage > ${CONTAINER_DIR}/${cntner}/cpu/cpu_usage.total_usage
		total_usage=$(cat ${CONTAINER_DIR}/${cntner}/cpu/cpu_usage.total_usage)
		cpuDelta=$((total_usage - previous_total_usage))

		# Uso total de cpu 
		previous_system_cpu_usage=$(cat ${CONTAINER_DIR}/${cntner}/cpu/system_cpu_usage)
        cat ${CONTAINER_DIR}/${cntner}/cntner.stats | jq .cpu_stats.system_cpu_usage > ${CONTAINER_DIR}/${cntner}/cpu/system_cpu_usage
		system_cpu_usage=$(cat ${CONTAINER_DIR}/${cntner}/cpu/system_cpu_usage)
		systemCpuDelta=$((system_cpu_usage - previous_system_cpu_usage))
	
		if [ ${cpuDelta} -ne 0 ] && [ ${systemCpuDelta} -ne 0 ]
		then
			cpuPercent=$(bc <<< "scale=5;($cpuDelta/$systemCpuDelta) * 100") 

			echo cpudelta: ${cpuDelta}
			echo systemCpuDelta: ${systemCpuDelta}
		
			echo cpuPercent: ${cpuPercent}
		fi




	done < ${TEMP_DIR}/containers.txt

   	sleep ${SLEEP_TIME}
	ls -l ${CONTAINER_DIR} | grep ^drwxr | awk '{print $9}' > ${TEMP_DIR}/containers.txt
done
	
	
	
	
 
