#!/bin/bash
#
# esse script é o responsavel por disponibilizar as estatisticas que são coletadas via chamadas da api do docker
#
#

source /opt/docker-monitor/docker-monitor_vars.sh

mkdir -p "$SYSTEM_DIR"
mkdir -p "$SYSTEM_STATS"
mkdir -p "$CONTAINER_DIR"
mkdir -p "$TEMP_DIR"
chmod 777 "$TEMP_DIR"

echo 0 > "$SYSTEM_DIR"/run.script
RUN_SCRIPT=$(cat "$SYSTEM_DIR"/run.script)

ps aux | grep -v grep | grep "/bin/bash $DIR_INSTALL_DOCKER_MONITOR/docker-monitor_2.sh" 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]
then
	/bin/bash "$DIR_INSTALL_DOCKER_MONITOR"/docker-monitor_2.sh & 
	echo "Iniciando o script 2"
	sleep 6
fi

while [ "$RUN_SCRIPT" -eq 0 ]
do
	startTime=$(date +%s)
	cat "$LISTA_CNTNER_EM_EXEC" > "$TEMP_DIR"/containers_t1.txt
	while read -r cntner
	do
		curl -XGET -s --unix-socket /var/run/docker.sock http:/v1.4/containers/${cntner}/stats?stream=false > "$TEMP_DIR"/cntner.stats
		cat "$TEMP_DIR"/cntner.stats > "$CONTAINER_DIR"/"$cntner"/cntner.stats 2>/dev/null
		rm -f "$TEMP_DIR"/cntner.stats
		
		#
		# Percorre os containers pegando a lista de interfaces de rede e gerando as estatisticas de utilização de cada uma delas
		#
		cat "$CONTAINER_DIR"/"$cntner"/cntner.stats | jq .networks | grep ": {" | sed -n -r 's/.*"(.*)".*/\1/p' > "$TEMP_DIR"/temp_network.txt
		while read neteth 
		do
			RUN_SCRIPT=$(cat "$SYSTEM_DIR"/run.script)
			if [ "$RUN_SCRIPT" -ne 0 ]
			then
				exit 0
			fi
			if [ ! -d "$CONTAINER_DIR"/"$cntner"/network/"$neteth" ]
			then
				mkdir "$CONTAINER_DIR"/"$cntner"/network/"$neteth"
			fi			
			cat "$CONTAINER_DIR"/"$cntner"/cntner.stats | jq .networks."$neteth".rx_bytes > "$CONTAINER_DIR"/"$cntner"/network/"$neteth"/rx_bytes
			cat "$CONTAINER_DIR"/"$cntner"/cntner.stats | jq .networks."$neteth".tx_bytes > "$CONTAINER_DIR"/"$cntner"/network/"$neteth"/tx_bytes
		done < "$TEMP_DIR"/temp_network.txt
		rm -f "$TEMP_DIR"/temp_network.txt
	
		#
		# disponibiliza a informação de inicialização do container
		#
		temp1=$(docker inspect --format='{{json .State.StartedAt}}' "$cntner")
		temp2=$(echo "$temp1" | tr -d "\"") 
		temp3=$(date --date="$temp2" +%s)
		echo "$temp3" > "$CONTAINER_DIR"/"$cntner"/system/startedAt 2>/dev/null
	done < "$TEMP_DIR"/containers_t1.txt
	rm -f "$TEMP_DIR"/containers_t1.txt

	finishTime=$(date +%s)
	timeExecution=$(("$finishTime"-"$startTime" ))

	if [ $timeExecution -le "$SLEEP_TIME" ]
	then
		sleep $(( "$SLEEP_TIME" - "$timeExecution" ))
	fi

	RUN_SCRIPT=$(cat "$SYSTEM_DIR"/run.script)
done
rm -f "$TEMP_DIR"/temp_network.txt
rm -f "$TEMP_DIR"/containers_t1.txt
rm -f "$TEMP_DIR"/cntner.stats

exit 0
