#!/bin/bash

ssh-keygen -t rsa -C "andrew@ways2code.com" -N "" -f ~/.ssh/id_rsa

ssh-copy-id vagrant@{{IP1}}
ssh-copy-id vagrant@{{IP2}}
ssh-copy-id vagrant@{{IP3}}

ansible-playbook -i /home/vagrant/config/HOSTS /home/vagrant/config/{{CLIENT}}/playbook/update.yml
ansible-playbook -i /home/vagrant/config/HOSTS /home/vagrant/config/{{CLIENT}}/playbook/httpd-install.yml
ansible-playbook -i /home/vagrant/config/HOSTS /home/vagrant/config/{{CLIENT}}/playbook/db-install.yml
ansible-playbook -i /home/vagrant/config/HOSTS /home/vagrant/config/{{CLIENT}}/playbook/api-install.yml

