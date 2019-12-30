#!/bin/bash

export SYSTEM_DIR=/dev/shm/docker-monitor
export DIR_INSTALL_DOCKER_MONITOR=/opt/docker-monitor

OPCAO=$1

case ${OPCAO} in
	start)
		ps aux | grep -v grep | grep "/bin/bash ${DIR_INSTALL_DOCKER_MONITOR}/docker-monitor_1.sh"
		if [ $? -eq 0 ]
		then
    		echo "já tem um processo executando"
    		exit 1
		else
			echo "Iniciando o script 1"
			/bin/bash ${DIR_INSTALL_DOCKER_MONITOR}/docker-monitor_1.sh &
		fi
	;;
	stop)
		echo 1 > ${SYSTEM_DIR}/run.script
	;;
       *)
		echo "Use para iniciar e parar a coleta das estatisticas."
		echo "Ex.: ./docker-monitor.sh start"
		echo "./docker-monitor.sh stop"
esac	
exit 0
