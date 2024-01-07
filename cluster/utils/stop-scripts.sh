#!/usr/bin/env bash

echo "Stop DFS and YARN"
/home/vagrant/hadoop/sbin/stop-all.sh
echo "Stop Hadoop history server"
/home/vagrant/hadoop/bin/mapred --daemon stop historyserver
echo "Stop Spark history server"
/home/vagrant/spark/sbin/stop-history-server.sh