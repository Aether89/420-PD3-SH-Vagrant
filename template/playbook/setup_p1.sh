#!/bin/bash

ssh-keygen -t rsa -C "andrew@ways2code.com" -N "" -f ~/.ssh/id_rsa

ssh-copy-id {{HTTPDADMIN}}@{{IP1}}

ansible-playbook -i /home/vagrant/config/HOSTS /home/vagrant/config/{{CLIENT}}/playbook/update.yml
ansible-playbook -i /home/vagrant/config/HOSTS /home/vagrant/config/{{CLIENT}}/playbook/httpd-install.yml
