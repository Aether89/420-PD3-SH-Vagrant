# IMPORTANT
le script pour configure postgres ne fonctionne pas, retourne plusieur erreur à chaque essaie que j'ai tenté/

## Étape manuelle si fonctionnait.
1 - Éxecuter init.ps1
2 - Se connecter à ansible
3 - lancer ~/config/client/playbook/setup.sh
3 - se conneter en ssh au serveur API
4 - lancer la commande psql -h <hostname_or_ip> -U NewTechUsr -d NewTech