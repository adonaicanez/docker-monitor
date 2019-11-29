#!/bin/bash

export SYSTEM_DIR=/dev/shm/docker-monitor


OPCAO=$1

case ${OPCAO} in
	start)
		bash docker-monitor_1.sh &
		exit 0
	;;
	stop)
		echo 1 > ${SYSTEM_DIR}/run.script
		exit 0
	;;
		*)
		echo "Use para iniciar e parar a coleta das estatisticas."
		echo "Ex.: ./docker-monitor.sh start"
		echo "./docker-monitor.sh stop"
esac	
