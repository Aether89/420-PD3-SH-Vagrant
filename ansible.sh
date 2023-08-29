#!/bin/bash

sudo apt update
sudo apt upgrade -y

sudo apt install python3-full python-is-python3 ansible expect -y

sudo apt autoremove -y

# ssh-keygen -t rsa -C "andrew@ways2code.com" -N "" -f ~/.ssh/id_rsa
# expect ./config/ssh-copy-id.expect vagrant 192.168.33.10 vagrant
# expect ./config/ssh-copy-id.expect vagrant 192.168.33.11 vagrant

# ansible-playbook -i ./config/ansible/hosts update.yml
# ansible-playbook -i ./config/ansible/hosts install-mariadb.yml
# ansible-playbook -i ./config/ansible/hosts configure-mariadb.yml
# ansible-playbook -i ./config/ansible/hosts add-user.yml
# ansible-playbook -i ./config/ansible/hosts install-httpd.yml
