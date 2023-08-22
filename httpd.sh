#!/bin/bash

sudo apt update
sudo apt upgrade -y

sudo apt install apache2 php8.2-common php8.2-mysql php8.2-xml php8.2-xmlrpc php8.2-curl php8.2-gd php8.2-imagick php8.2-cli php8.2-dev php8.2-imap php8.2-mbstring php8.2-opcache php8.2-soap php8.2-zip php8.2-redis php8.2-intl mariadb-client libapache2-mod-php8.2 -y 

sudo apt autoremove -y


sudo a2enmod php8.2
sudo systemctl restart apache2

