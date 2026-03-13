# Hadoop 3.3.6 + Hive 2.3.9 — Docker Compose Lab

## Topology

```
Host Machine (Mac/Linux)
│
├── master  (172.20.0.20)  ← NameNode + ResourceManager + HiveServer2
├── slave1  (172.20.0.21)  ← DataNode + NodeManager
├── slave2  (172.20.0.22)  ← DataNode + NodeManager
└── mysql   (172.20.0.10)  ← Hive Metastore
```

## Web UIs (sau khi cluster up)

| Service              | URL                        |
|----------------------|----------------------------|
| HDFS NameNode        | http://localhost:9870       |
| YARN ResourceManager | http://localhost:8088       |
| HiveServer2 Web UI   | http://localhost:10002      |
| MapReduce History    | http://localhost:19888      |
| DataNode slave1      | http://localhost:9864       |
| DataNode slave2      | http://localhost:9865       |

## Khởi động

```bash
# 1. Clone / giải nén thư mục này vào máy
cd hadoop-hive-lab

# 2. Build và start toàn bộ cluster (~10-15 phút lần đầu)
COMPOSE_PARALLEL_LIMIT=1 docker compose build && docker compose up -d
# 3. Theo dõi quá trình khởi động master
docker logs -f master
# Chờ đến khi thấy: "HiveServer2 started"
```

## Dùng Hive

### Cách 1 — Hive CLI (trực tiếp trong container)
```bash
docker exec -it master sudo -u hduser hive
```

### Cách 2 — Beeline (JDBC, giống slide 29)
```bash
docker exec -it master sudo -u hduser beeline \
  -u "jdbc:hive2://localhost:10000" \
  -n hduser
```

### Cách 3 — Beeline từ máy host (nếu đã cài beeline)
```bash
beeline -u "jdbc:hive2://localhost:10000" -n hduser
```

## Ví dụ tạo bảng và query (slide 30+)

```sql
-- Tạo database
CREATE DATABASE lab_db;
USE lab_db;

-- Tạo bảng
CREATE TABLE employees (
  id INT,
  name STRING,
  salary DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Load data
LOAD DATA LOCAL INPATH '/path/to/data.csv' INTO TABLE employees;

-- Query
SELECT * FROM employees LIMIT 10;
```

## Kiểm tra cluster

```bash
# Kiểm tra DataNodes
docker exec -it master sudo -u hduser hdfs dfsadmin -report

# Kiểm tra YARN nodes
docker exec -it master sudo -u hduser yarn node -list

# Kiểm tra Hive Metastore
docker exec -it master sudo -u hduser schematool -dbType mysql -info
```

## Dừng / Xóa

```bash
# Dừng (giữ data)
docker compose stop

# Start lại
docker compose start

# Xóa hoàn toàn (bao gồm data volumes)
docker compose down -v
```

## Cấu trúc thư mục

```
hadoop-hive-lab/
├── docker-compose.yml
├── Dockerfile.base      # Ubuntu + Java + Hadoop (dùng chung)
├── Dockerfile.master    # master + Hive + MySQL Connector
├── Dockerfile.slave     # slave (DataNode/NodeManager)
├── entrypoint-master.sh
├── entrypoint-slave.sh
├── init-mysql.sql
├── conf/
│   ├── hadoop/
│   │   ├── core-site.xml
│   │   ├── hdfs-site.xml
│   │   ├── yarn-site.xml
│   │   ├── mapred-site.xml
│   │   └── workers
│   └── hive/
│       ├── hive-site.xml
│       └── hive-env.sh
└── README.md
```
