-- Cấp quyền đầy đủ cho hivedb_user từ mọi host trong Docker network
GRANT ALL PRIVILEGES ON hivedb.* TO 'hivedb_user'@'%' IDENTIFIED BY 'Hive@123';
GRANT ALL PRIVILEGES ON hivedb.* TO 'root'@'%' IDENTIFIED BY 'admin@123';
FLUSH PRIVILEGES;
