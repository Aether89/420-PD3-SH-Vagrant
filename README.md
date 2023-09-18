# IMPORTANT
le playbook db-configure cause postegresql a failed pour se relancer
le playbook db-add-user timeeout pour l'authentification.


## Étape manuelle si fonctionnait pour tester la connection
1 - Éxecuter init.ps1
 - suivre les prompts à l'écran
2 - Se connecter à ansible
3 - lancer ~/config/client/playbook/setup.sh
3 - se conneter en ssh au serveur API
4 - lancer la commande psql -h <hostname_or_ip> -U NewTechUsr -d NewTech
