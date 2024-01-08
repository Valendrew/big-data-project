#!/usr/bin/env bash

echo "Start DFS and YARN"
/home/vagrant/hadoop/sbin/start-dfs.sh
/home/vagrant/hadoop/sbin/start-yarn.sh
echo "Start Hadoop history server"
/home/vagrant/hadoop/bin/mapred --daemon start historyserver
echo "Start Spark history server"
/home/vagrant/spark/sbin/start-history-server.sh