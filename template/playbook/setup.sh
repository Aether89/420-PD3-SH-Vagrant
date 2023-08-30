#!/bin/bash

ssh-keygen -t rsa -C "andrew@ways2code.com" -N "" -f ~/.ssh/id_rsa
ssh-copy-id vagrant@{{IP1}}
ssh-copy-id vagrant@{{IP2}}
ssh-copy-id vagrant@{{IP3}}


ansible-playbook -i /home/vagrant/config/ansible/hosts /home/vagrant/config/ansible/update.yml
ansible-playbook -i /home/vagrant/config/ansible/hosts /home/vagrant/config/ansible/install-mariadb.yml
ansible-playbook -i /home/vagrant/config/ansible/hosts /home/vagrant/config/ansible/configure-mariadb.yml
ansible-playbook -i /home/vagrant/config/ansible/hosts /home/vagrant/config/ansible/add-user.yml
ansible-playbook -i /home/vagrant/config/ansible/hosts /home/vagrant/config/ansible/install-httpd.yml
