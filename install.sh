#!/bin/bash

cp systemd/docker-monitor.service /etc/systemd/system/

mkdir /opt/docker-monitor/
cp opt/docker-monitor/docker-monitor.sh /opt/docker-monitor/
cp opt/docker-monitor/docker-monitor_1.sh /opt/docker-monitor/
cp opt/docker-monitor/docker-monitor_2.sh /opt/docker-monitor/

cp autodiscovery/docker-interfaces.sh /opt/docker-monitor/
cp autodiscovery/docker-discovery.sh /opt/docker-monitor/

