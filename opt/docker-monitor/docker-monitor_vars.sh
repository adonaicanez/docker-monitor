#!/bin/bash

export SLEEP_TIME=100

export DIR_INSTALL_DOCKER_MONITOR=/opt/docker-monitor

export SYSTEM_DIR=/dev/shm/docker-monitor
export CONTAINER_DIR=${SYSTEM_DIR}/container
export TEMP_DIR=${SYSTEM_DIR}/temp
export SYSTEM_STATS=${SYSTEM_DIR}/system

export LISTA_CNTNER_EM_EXEC=${SYSTEM_STATS}/containers_execucao.txt
