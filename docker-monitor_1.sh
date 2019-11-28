#!/bin/bash

export SYSTEM_DIR=/dev/shm/docker-monitor
export CONTAINER_DIR=${SYSTEM_DIR}/container
export SYSTEM_STATS=${SYSTEM_DIR}/system
export TEMP_DIR=${SYSTEM_DIR}/temp

export LISTA_CNTNER_EM_EXEC=${TEMP_DIR}/containers_execucao.txt

export DIR_INSTALL_DOCKER_MONITOR=/srv/docker-monitor
SLEEP_TIME=5

mkdir -p ${SYSTEM_DIR}
mkdir -p ${SYSTEM_STATS}
mkdir -p ${CONTAINER_DIR}
mkdir -p ${TEMP_DIR}
chmod 777 ${TEMP_DIR}

echo 0 > ${SYSTEM_DIR}/run.script
RUN_SCRIPT=$(cat ${SYSTEM_DIR}/run.script)

/bin/bash ${DIR_INSTALL_DOCKER_MONITOR}/docker-monitor_2.sh & 
sleep 6

while [ ${RUN_SCRIPT} -eq 0 ]
do
	cat ${LISTA_CNTNER_EM_EXEC} > ${TEMP_DIR}/containers_t1.txt
	while read cntner
	do
		curl -XGET -s --unix-socket /var/run/docker.sock http:/v1.4/containers/${cntner}/stats?stream=false > ${TEMP_DIR}/cntner.stats
		cat ${TEMP_DIR}/cntner.stats > ${CONTAINER_DIR}/${cntner}/cntner.stats

		#
		# Percorre os containers pegando a lista de interfaces de rede e gerando as estatisticas de utilização de cada uma delas
		#
		cat ${CONTAINER_DIR}/${cntner}/cntner.stats | jq .networks | grep ": {" | sed -n -r 's/.*"(.*)".*/\1/p' > ${TEMP_DIR}/temp_network.txt
		while read neteth 
		do
			RUN_SCRIPT=$(cat ${SYSTEM_DIR}/run.script)
			if [ ${RUN_SCRIPT} -ne 0 ]
			then
				exit 0
			fi
			if [ ! -d ${CONTAINER_DIR}/${cntner}/network/${neteth} ]
			then
				mkdir ${CONTAINER_DIR}/${cntner}/network/${neteth}
			fi			
			cat ${CONTAINER_DIR}/${cntner}/cntner.stats | jq .networks.${neteth}.rx_bytes > ${CONTAINER_DIR}/${cntner}/network/${neteth}/rx_bytes
			cat ${CONTAINER_DIR}/${cntner}/cntner.stats | jq .networks.${neteth}.tx_bytes > ${CONTAINER_DIR}/${cntner}/network/${neteth}/tx_bytes
		done < ${TEMP_DIR}/temp_network.txt
		
		#
		# disponibiliza a informação de inicialização do container
		#
		temp1=$(docker inspect --format='{{json .State.StartedAt}}' ${cntner})
		temp2=$(echo $temp1 | tr -d "\"") 
		temp3=$(date --date="$temp2" +%s)
		echo $temp3 > ${CONTAINER_DIR}/${cntner}/system/startedAt

		echo "executando container: ${cntner}"
   		sleep ${SLEEP_TIME}
	done < ${TEMP_DIR}/containers_t1.txt
	RUN_SCRIPT=$(cat ${SYSTEM_DIR}/run.script)
done
exit 0
