#!/bin/bash

export SYSTEM_DIR=/dev/shm/docker-monitor
export DIR_INSTALL_DOCKER_MONITOR=/opt/docker-monitor

OPCAO=$1

case ${OPCAO} in
	start)
		/bin/bash ${DIR_INSTALL_DOCKER_MONITOR}/docker-monitor_1.sh &
		echo $#
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
