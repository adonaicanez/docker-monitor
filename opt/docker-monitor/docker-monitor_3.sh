#!/bin/bash 
#
# Esse script é o responsavel por disponibilizar as estatisticas geradas pelo comando "docker system df -v"
#
SLEEP_TIME_CNTR_SIZE=300

docker system df -v | grep -A 100 "CONTAINER ID" | grep -B 100 "\n" | grep -v Exited> ${TEMP_DIR}/container.size.tmp

RUN_SCRIPT=$(cat ${SYSTEM_DIR}/run.script)
while read linha
do


	RUN_SCRIPT=$(cat ${SYSTEM_DIR}/run.script)
done < ${TEMP_DIR}/container.size.tmp
