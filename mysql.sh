#!/bin/bash

sudo apt update
sudo apt upgrade -y

sudo apt install mariadb-server mariadb-client -y

sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'ChuckIsGreat543';"

sudo mysql -uroot -pChuckIsGreat543 -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -uroot -pChuckIsGreat543 -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -uroot -pChuckIsGreat543 -e "DROP DATABASE IF EXISTS test;"
sudo mysql -uroot -pChuckIsGreat543 -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -uroot -pChuckIsGreat543 -e "FLUSH PRIVILEGES"

sudo mysql -uroot -pChuckIsGreat543 -e "CREATE DATABASE IF NOT EXISTS NewTech;"
sudo mysql -uroot -pChuckIsGreat543 -e "CREATE USER 'NewTech'@'%' IDENTIFIED BY 'lopl8788';"
sudo mysql -uroot -pChuckIsGreat543 -e "GRANT ALL PRIVILEGES ON NewTech.* TO 'NewTech'@'%';"
sudo mysql -uroot -pChuckIsGreat543 -e "FLUSH PRIVILEGES"

sudo apt autoremove -y

sudo cp /etc/mysql/mariadb.conf.d/50-server.cnf ~/50-server.cnf.bak
sudo sed -i '/^\s*bind-address\s*=/ s/127\.0\.0\.1/0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

sudo systemctl stop mysql
sudo systemctl start mysql 