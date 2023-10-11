#!/bin/bash

ssh-copy-id {{APIADMIN}}@{{IP2}}
ssh-copy-id {{DBADMIN}}@{{IP3}}

ansible-playbook -i /home/vagrant/config/HOSTS /home/vagrant/config/{{CLIENT}}/playbook/update.yml
ansible-playbook -i /home/vagrant/config/HOSTS /home/vagrant/config/{{CLIENT}}/playbook/db-install.yml
ansible-playbook -i /home/vagrant/config/HOSTS /home/vagrant/config/{{CLIENT}}/playbook/api-install.yml
