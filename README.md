# Read Me !
## Prérequis
- Powershell
  - Install-Module -Name Az -Repository PSGallery -Force
- vagrant
- azure 
- git
- github cli
  - variable système pour GIT_ACCESS_TOKEN

## Utilisation

1 - Lancer le script powershell (./prob2_p1.ps1)
2 - Suive les instruction affiché dans la console
3 - Démarrer la machine virtuelle Ansible (vagrant up)
4 - Connecter à la machine virtuelle Ansible (vagrant ssh ansible)
5 - Lancer le script de setup /home/vagrant/config/{{CLIENT}}/playbook/setup.sh 
