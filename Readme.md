# Prérequis

1. VisualStudio Code
2. REST Client extension pour VisualStudio Code (humao.rest-client)
3. Docker
4. node.js

# Installation

1. Ouvrir Docker.
2. Ouvrir un terminal à la racine du projet
3. Executer la commande npm install
4. Executer la commande docker build -t demolive ./
5. Executer la commande docker-compose up

# Test
1. Ouvrir le fichier test.rest
2. Cliquer sur Send Request au dessus de GET http://localhost:13370/setup
3. Cliquer sur Send Request au dessus de 
POST http://localhost:13370
Content-Type: application/json

{
    "name": "Bob",
    "location": "New York"
}
4. Cliquer sur Send Request au dessus de GET http://localhost:13370
5. faire un changement dans server.js , recommandation de ligne 12 ou 27.
6. Retourner dans test.rest et cliquer sur le Send Request associé à la ligne modifier.
