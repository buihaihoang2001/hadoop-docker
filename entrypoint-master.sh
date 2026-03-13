#!/bin/bash
set -e

echo "====== [MASTER] Starting SSH daemon ======"
service ssh start

# Chờ slave1 và slave2 SSH sẵn sàng
for host in slave1 slave2; do
  echo ">>> Waiting for SSH on $host ..."
  until nc -z "$host" 22 2>/dev/null; do sleep 2; done
  echo ">>> $host SSH ready"
done

# Format NameNode lần đầu (flag file tránh format lại khi restart)
FORMATTED=/hadoop/dfs/name/.formatted
if [ ! -f "$FORMATTED" ]; then
  echo "====== [MASTER] Formatting NameNode ======"
  sudo -u hduser $HADOOP_HOME/bin/hdfs namenode -format -force -nonInteractive
  touch "$FORMATTED"
fi

echo "====== [MASTER] Starting HDFS ======"
sudo -u hduser $HADOOP_HOME/sbin/start-dfs.sh

echo "====== [MASTER] Starting YARN ======"
sudo -u hduser $HADOOP_HOME/sbin/start-yarn.sh

echo "====== [MASTER] Starting MapReduce History Server ======"
sudo -u hduser $HADOOP_HOME/bin/mapred --daemon start historyserver

# Tạo thư mục HDFS cần thiết cho Hive
echo "====== [MASTER] Creating HDFS directories ======"
sudo -u hduser $HADOOP_HOME/bin/hdfs dfs -mkdir -p /tmp
sudo -u hduser $HADOOP_HOME/bin/hdfs dfs -mkdir -p /hive/warehouse
sudo -u hduser $HADOOP_HOME/bin/hdfs dfs -chmod g+w /tmp
sudo -u hduser $HADOOP_HOME/bin/hdfs dfs -chmod g+w /hive/warehouse

# Chờ MySQL
echo "====== [MASTER] Waiting for MySQL ======"
until nc -z mysql 3306 2>/dev/null; do sleep 3; done
echo ">>> MySQL ready"

# Khởi tạo Hive Metastore schema (chỉ lần đầu)
SCHEMA_DONE=/tmp/.hive_schema_initialized
if [ ! -f "$SCHEMA_DONE" ]; then
  echo "====== [MASTER] Initializing Hive Metastore schema ======"
  sudo -u hduser $HIVE_HOME/bin/schematool -dbType mysql -initSchema
  touch "$SCHEMA_DONE"
fi

echo "====== [MASTER] Starting HiveServer2 ======"
exec sudo -u hduser $HIVE_HOME/bin/hiveserver2 \
  --hiveconf hive.server2.enable.doAs=false \
  --hiveconf hive.root.logger=INFO,console
