CREATE DATABASE hive DEFAULT CHARACTER SET utf8;
SHOW DATABASES;

CREATE USER 'hive'@'localhost' IDENTIFIED BY 'hive';
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'localhost';
CREATE USER 'hive'@'%' IDENTIFIED BY 'hive';
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%';
FLUSH PRIVILEGES;

select Host,User,Password from mysql.user where User='hive';
