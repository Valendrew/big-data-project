#!/usr/bin/env bash

echo "Stop DFS and YARN"
/home/vagrant/hadoop/sbin/stop-dfs.sh
/home/vagrant/hadoop/sbin/stop-yarn.sh
echo "Stop Hadoop history server"
/home/vagrant/hadoop/bin/mapred --daemon stop historyserver
echo "Stop Spark history server"
/home/vagrant/spark/sbin/stop-history-server.sh