#!/bin/bash
  
BASE_DIRECTORY_RAM_NET=/dev/shm/docker-monitor/
BASE_DIRECTORY_RAM_NET_CONTAINER=${BASE_DIRECTORY_RAM_NET}container/
BASE_DIRECTORY_RAM_NET_TEMP=${BASE_DIRECTORY_RAM_NET}temp/

DOCKER_SOCK_FILE_NET=${BASE_DIRECTORY_RAM_NET_TEMP}docker-network-sock.json.tmp
DOCKER_NETWORK_FILE=${BASE_DIRECTORY_RAM_NET_TEMP}docker-network.json.tmp

curl -XGET -s --unix-socket /var/run/docker.sock "http:/v1.4/containers/json?all=0" > ${DOCKER_SOCK_FILE_NET}

i=$( jq length ${DOCKER_SOCK_FILE_NET} )

echo -ne "{\n" 
echo -ne "\t\"data\":[\n\n"

while [ $i -gt 0 ]
do

    let i=$i-1
    containerName=$(jq .[$i].Names[0] ${DOCKER_SOCK_FILE_NET} | cut -d '"' -f 2 | sed 's/^.\{1\}//')
    curl -XGET -s --unix-socket /var/run/docker.sock "http:/v1.4/containers/${containerName}/stats?stream=false" | jq '.networks | keys' > ${DOCKER_NETWORK_FILE}
    j=$( jq length ${DOCKER_NETWORK_FILE} )

    while [ $j -gt 0 ]
    do
        let j=$j-1
        containerNetwork=$(jq .[$j] ${DOCKER_NETWORK_FILE} | cut -d '"' -f 2 )
		if [ $j -eq 0 -a $i -eq 0 ]
		then
        	echo -ne "\t{\"{#CONTAINERNAME}\":\"${containerName}\",\t\t\t\t\"{#CONTAINERINTERFACE}\":\"${containerNetwork}\"}\n"
		else
      		echo -ne "\t{\"{#CONTAINERNAME}\":\"${containerName}\",\t\t\t\t\"{#CONTAINERINTERFACE}\":\"${containerNetwork}\"},\n"
		fi
    done
done

rm -rf BASE_DIRECTORY_RAM_NET_TEMP*

echo -e "\n\t]" 
echo "}"