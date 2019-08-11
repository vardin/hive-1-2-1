#!/bin/bash

# mariadb 
service mysql start
service mysql status

# hcatalog
${HIVE_HOME}/hcatalog/sbin/hcat_server.sh start

# webhcatalog
${HIVE_HOME}/hcatalog/sbin/webhcat_server.sh start

# hiveserver2
#mkdir -p /var/log/hive
#nohup ${HIVE_HOME}/bin/hiveserver2 > /var/log/hive/hiveserver2.out 2> /var/log/hive/hiveserver2.log &
${HIVE_HOME}/bin/hiveserver2 &

