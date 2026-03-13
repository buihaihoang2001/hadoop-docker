#!/bin/bash
set -e

echo "====== [$(hostname)] Starting SSH daemon ======"
service ssh start

echo "====== [$(hostname)] Starting DataNode ======"
sudo -u hduser $HADOOP_HOME/bin/hdfs --daemon start datanode

echo "====== [$(hostname)] Starting NodeManager ======"
sudo -u hduser $HADOOP_HOME/bin/yarn --daemon start nodemanager

echo "====== [$(hostname)] All services up — tailing logs ======"
tail -f $HADOOP_HOME/logs/*.log 2>/dev/null || tail -f /dev/null
