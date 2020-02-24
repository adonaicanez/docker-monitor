#!/bin/bash

function converte_byte () {
	valor="$(echo "$1" | sed -n -r 's/([[:digit:]\.]*).*/\1/p')"
	unidade="$(echo "$1" | sed -n -r 's/([[:digit:]\.]*)(.*)/\2/p')"

	case $unidade in
		B)
			result_func="$valor"
		;;
		kB) 
			result_func=$(echo "$valor"*1024 | bc)			
		;;
		MiB)
			result_func=$(echo "$valor"*1024*1024 | bc)
		;;
		MB)
			result_func=$(echo "$valor"*1024*1024 | bc)
        ;;
		GiB)
			result_func=$(echo "$valor"*1024*1024*1024 | bc)
		;;
	esac
}

RUN_SCRIPT=$(cat "$SYSTEM_DIR"/run.script)
while [ "$RUN_SCRIPT" -eq 0 ]
do
	startTime=$(date +%s)
    docker stats --no-stream | grep -v "CONTAINER ID" > "$TEMP_DIR"/docker.stats.ctnr
	awk '{print $2}' "$TEMP_DIR"/docker.stats.ctnr > "$LISTA_CNTNER_EM_EXEC"
	
	#
	# Mantem a lista de containers em execução atualizada, removendo diretorios de containers que foram parados
	#
	/bin/ls -l "$CONTAINER_DIR" | grep ^drwxr | awk '{print $9}' > "$TEMP_DIR"/containers_ls_t2.txt
	while read dircont
	do
		grep "$dircont" "$LISTA_CNTNER_EM_EXEC" 1>/dev/null 2>/dev/null
		if [ $? -ne 0 ]
		then
			rm -rf  "${CONTAINER_DIR:?}"/"${dircont:?}"	
		fi
	done < "$TEMP_DIR"/containers_ls_t2.txt 	
	rm -f "${TEMP_DIR:?}"/containers_ls_t2.txt

	#
	# Cria a estrutura de diretórios dos containers em execução 
	# 
	while read cntner 
    do
		container=$(echo "$cntner" | awk '{print $2}')
		if [ ! -d "$CONTAINER_DIR"/"$container" ]
        then
			mkdir "$CONTAINER_DIR"/"$container"
			mkdir "$CONTAINER_DIR"/"$container"/cpu
			mkdir "$CONTAINER_DIR"/"$container"/memory
			mkdir "$CONTAINER_DIR"/"$container"/network
			mkdir "$CONTAINER_DIR"/"$container"/disc
			mkdir "$CONTAINER_DIR"/"$container"/system
		fi

		temp1=$(echo "$cntner" | awk '{print $3}')
		temp2=$(echo "$temp1" | sed -n -r 's/(.*)%/\1/p')
		echo $temp2 > ${CONTAINER_DIR}/${container}/cpu/usage
		
		temp1=$(echo "$cntner" | awk '{print $4}')
		converte_byte "$temp1"
		echo $result_func > "$CONTAINER_DIR"/"$container"/memory/usage

		temp1=$(echo "$cntner" | awk '{print $6}')
		converte_byte "$temp1"
		echo $result_func > "$CONTAINER_DIR"/"$container"/memory/limit
	
		temp1=$(echo "$cntner" | awk '{print $7}')
		temp2=$(echo "$temp1" | sed -n -r 's/(.*)%/\1/p')
		echo "$temp2" > "$CONTAINER_DIR"/"$container"/memory/percent

		temp1=$(echo "$cntner" | awk '{print $8}')
		converte_byte "$temp1"
		echo $result_func > "$CONTAINER_DIR"/"$container"/network/total_rx

		temp1=$(echo "$cntner" | awk '{print $10}')
		converte_byte "$temp1"
		echo $result_func > "$CONTAINER_DIR"/"$container"/network/total_tx

		temp1=$(echo "$cntner" | awk '{print $11}')
		converte_byte "$temp1"
		echo $result_func > "$CONTAINER_DIR"/"$container"/disc/block_read

		temp1=$(echo $cntner | awk '{print $13}')
		converte_byte "$temp1"
		echo "$result_func" > "$CONTAINER_DIR"/"$container"/disc/block_write

    done < "$TEMP_DIR"/docker.stats.ctnr
	rm -f "${TEMP_DIR:?}/"docker.stats.ctnr
	
    finishTime=$(date +%s)
    timeExecution=$(("$finishTime"-"$startTime"))

    if [ "$timeExecution" -le "$SLEEP_TIME" ]
    then
        sleep $(( "$SLEEP_TIME" - "$timeExecution" ))
    fi

	RUN_SCRIPT=$(cat "$SYSTEM_DIR"/run.script)
done
rm -f "${TEMP_DIR:?}"/docker.stats.ctnr
rm -f "${TEMP_DIR:?}"/containers_ls_t2.txt

exit 0
