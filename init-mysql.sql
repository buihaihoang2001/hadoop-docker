-- MySQL 8.x: tách GRANT và ALTER USER riêng
ALTER USER 'hivedb_user'@'%' IDENTIFIED WITH mysql_native_password BY 'Hive@123';
GRANT ALL PRIVILEGES ON hivedb.* TO 'hivedb_user'@'%';
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'admin@123' ;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;