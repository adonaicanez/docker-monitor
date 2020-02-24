#!/bin/bash
 
DOCKER_API=v1.4

BASE_DIRECTORY_RAM=/dev/shm/docker-monitor/
#BASE_DIRECTORY_RAM_CONTAINER=${BASE_DIRECTORY_RAM}container/
BASE_DIRECTORY_RAM_TEMP=${BASE_DIRECTORY_RAM}temp/
DOCKER_SOCK_FILE=${BASE_DIRECTORY_RAM_TEMP}docker-sock.json.tmp

if [ -f "$DOCKER_SOCK_FILE" ]
then
    rm -f ${DOCKER_SOCK_FILE}
fi

curl -XGET -s --unix-socket /var/run/docker.sock http:/${DOCKER_API}/containers/json?all=0 > $DOCKER_SOCK_FILE

i=$( jq length $DOCKER_SOCK_FILE )

echo -ne "{\n"
echo -ne "\t\"data\":[\n\n"

while [ "$i" -gt 0 ]
do
    let i=$i-1
    if [ $i -eq 0 ]
    then
        containerName=$(jq .[$i].Names[0] $DOCKER_SOCK_FILE | cut -d '"' -f 2 | sed 's/^.\{1\}//')
        echo -ne "\t{\"{#CONTAINERNAME}\":\"${containerName}\"}\n"
    else
        containerName=$(jq .[$i].Names[0] $DOCKER_SOCK_FILE | cut -d '"' -f 2 | sed 's/^.\{1\}//')
        echo -ne "\t{\"{#CONTAINERNAME}\":\"${containerName}\"},\n"
    fi
done

echo -e "\n\t]"
echo "}"
