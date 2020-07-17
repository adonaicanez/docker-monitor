#!/bin/bash
#
# Instalador do docker-monitor desenvolvido e testado no Debian 10
#
# 

apt-get install -y bc jq curl

cp -f systemd/docker-monitor.service /etc/systemd/system/

systemctl daemon-reload

if [ ! -e  /opt/docker-monitor ]
then
	mkdir /opt/docker-monitor/
fi

# Copiando os arquivos do modulo de monitoramento e geração das estatisticas
cp -f opt/docker-monitor/docker-monitor.sh /opt/docker-monitor/
cp -f opt/docker-monitor/docker-monitor_1.sh /opt/docker-monitor/
cp -f opt/docker-monitor/docker-monitor_2.sh /opt/docker-monitor/
cp -f opt/docker-monitor/docker-monitor_vars.sh /opt/docker-monitor/

# Copiando os arquivos de discovery do zabbix
cp -f autodiscovery/docker-interfaces.sh /opt/docker-monitor/
cp -f autodiscovery/docker-discovery.sh /opt/docker-monitor/

chmod 750 /opt/docker-monitor/docker-monitor.sh
chmod 750 /opt/docker-monitor/docker-monitor_1.sh
chmod 750 /opt/docker-monitor/docker-monitor_2.sh
chmod 750 /opt/docker-monitor/docker-monitor_vars.sh
chmod 750 /opt/docker-monitor/docker-interfaces.sh
chmod 750 /opt/docker-monitor/docker-discovery.sh

chown zabbix:zabbix /opt/docker-monitor/docker-monitor.sh
chown zabbix:zabbix /opt/docker-monitor/docker-monitor_1.sh
chown zabbix:zabbix /opt/docker-monitor/docker-monitor_2.sh
chown zabbix:zabbix /opt/docker-monitor/docker-monitor_vars.sh
chown zabbix:zabbix /opt/docker-monitor/docker-interfaces.sh
chown zabbix:zabbix /opt/docker-monitor/docker-discovery.sh

usermod -a -G docker zabbix

if [ -e  /etc/zabbix/zabbix_agentd.d ]
then
	cp -f etc/zabbix/zabbix_agentd.conf.d/userparameter_docker-monitor.conf /etc/zabbix/zabbix_agentd.d/userparameter_docker-monitor.conf
else
	echo "Não foi possivel localizar a pasta de userparameters do agente do zabbix, verifique se o agente esta instalado"
fi

systemctl enable docker-monitor.service
systemctl start docker-monitor.service
