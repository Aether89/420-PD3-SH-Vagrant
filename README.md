# Read Me !
## Prérequis
- Powershell
  - Install-Module -Name Az -Repository PSGallery -Force
- vagrant
- azure 
- git
- github cli
  - variable système pour GIT_ACCESS_TOKEN

## Option 1 Préparation HTTPD, API & DB (Tous en un)

1. Lancer le script powershell (./prob2.ps1)
2. Suive les instruction affiché dans la console
3. Démarrer la machine virtuelle Ansible (vagrant up)
4. Connecter à la machine virtuelle Ansible (vagrant ssh ansible)
5. Lancer le script de setup /home/vagrant/config/{{CLIENT}}/playbook/setup.sh 

## Option 2 Préparation seuls
## * non fonctionnell erreur avec les scripts pour copier les fichiers dans le dossier config ainsi que leur modification
## Partie 1 HTTPD
1. Lancer le script powershell (./prob2_p1.ps1)
2. Suive les instruction affiché dans la console
3. Démarrer la machine virtuelle Ansible (vagrant up)
4. Connecter à la machine virtuelle Ansible (vagrant ssh ansible)
5. Lancer le script de setup /home/vagrant/config/{{CLIENT}}/playbook/setup_p1.sh 

### Parti 2 API & DB
1. Lancer le script powershell (./prob2_p2.ps1)
2. Suive les instruction affiché dans la console
3. Connecter à la machine virtuelle Ansible (vagrant ssh ansible)
4. Lancer le script de setup /home/vagrant/config/{{CLIENT}}/playbook/setup_p2.sh 
