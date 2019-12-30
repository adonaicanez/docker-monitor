#!/bin/bash 
#
# Esse script é o responsavel por disponibilizar as estatisticas disponibilizadas pelo comando "docker system df -v"
#

docker system df -v | grep -A 100 "CONTAINER ID" | grep -B 100 "\n"
