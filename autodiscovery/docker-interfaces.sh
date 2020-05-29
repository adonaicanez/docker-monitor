#!/bin/bash
  
BASE_DIRECTORY_RAM_NET=/dev/shm/docker-monitor/
BASE_DIRECTORY_RAM_NET_CONTAINER=${BASE_DIRECTORY_RAM_NET}container/
BASE_DIRECTORY_RAM_NET_TEMP=${BASE_DIRECTORY_RAM_NET}temp/

ls -1 ${BASE_DIRECTORY_RAM_NET_CONTAINER} > ${BASE_DIRECTORY_RAM_NET_TEMP}containers.tmp
i=$( cat ${BASE_DIRECTORY_RAM_NET_TEMP}containers.tmp | wc -l )

echo -ne "{\n" 
echo -ne "\t\"data\":[\n\n"

while [ "$i" -gt 0 ]
do
    containerName=$(cat ${BASE_DIRECTORY_RAM_NET_TEMP}containers.tmp | awk "NR==${i}"  )
    ls -1 ${BASE_DIRECTORY_RAM_NET_CONTAINER}${containerName}/network | grep -v total > ${BASE_DIRECTORY_RAM_NET_TEMP}interfaces.tmp 
    j=$( cat ${BASE_DIRECTORY_RAM_NET_TEMP}interfaces.tmp | wc -l )
    while [ "$j" -gt 0 ]
    do
	    containerNetwork=$(	cat ${BASE_DIRECTORY_RAM_NET_TEMP}interfaces.tmp | awk "NR==${j}" ) 
	    if [ "$i" -eq 1 -a "$j" -eq 1 ]
    		then
     			echo -ne "\t{\"{#CONTAINERNAME}\":\"${containerName}\",\t\t\t\t\"{#CONTAINERINTERFACE}\":\"${containerNetwork}\"}\n"
    		else
    			echo -ne "\t{\"{#CONTAINERNAME}\":\"${containerName}\",\t\t\t\t\"{#CONTAINERINTERFACE}\":\"${containerNetwork}\"},\n"
	    fi
	    let j=$j-1
    done
    let i=$i-1
done

rm -rf BASE_DIRECTORY_RAM_NET_TEMP*

echo -e "\n\t]" 
echo "}"
