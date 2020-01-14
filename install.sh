#!/bin/bash

cp -f systemd/docker-monitor.service /etc/systemd/system/

systemctl daemon-reload

if [ ! -e  /opt/docker-monitor ]
then
	mkdir /opt/docker-monitor/
fi

cp -f opt/docker-monitor/docker-monitor.sh /opt/docker-monitor/
cp -f opt/docker-monitor/docker-monitor_1.sh /opt/docker-monitor/
cp -f opt/docker-monitor/docker-monitor_2.sh /opt/docker-monitor/

cp -f autodiscovery/docker-interfaces.sh /opt/docker-monitor/
cp -f autodiscovery/docker-discovery.sh /opt/docker-monitor/

usermod -a -G docker zabbix
