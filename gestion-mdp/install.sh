#!/bin/bash
#set -x
#Verification si docker est installé
type docker 2>/dev/null >/dev/null
OK=$?
if [ $OK = 1 ];then
	echo "Docker n'est pas installé, installez le"
        exit 1
else
	echo "Commande docker OK"
fi
WD=`pwd`
read -p "Répertoire d'installation ($PWD) :" mypwd
echo $mypwd
if [ "$mypwd" = "" ];then
	mypwd=$PWD
fi
cd $mypwd
echo "Installation dans $mypwd"
if [ ! -d "$mypwd" ];then
	echo "Vous devez creer le repertoire $mypwd"
	exit 1;
fi
echo "Téléchargement de docker-compose"
curl -L 'https://raw.githubusercontent.com/Libertech-FR/sesame-exemple/main/gestion-mdp/docker-compose.yml' >docker-compose.yml
read -p "Url du serveur sesame-orchestrator (http(s)://(nom|ip):" HOST
# creation du reseau sesame
echo "Création du réseau docker sesame"
docker network create sesame
echo "Veuillez créer un jeton d'authentification sur sesame-orchestrator avec le commande : #make sesame-generate-jwt-secret"
read -p "Recopier ici le jeton généré par la commande ci-dessus :" JETON
echo "Géneration de .env"
echo "API_URL=$HOST" >.env
echo "API_KEY=$JETON" >>.env
if [ ! -d "./config/img" ];then
  mkdir -p config/img
  curl -L "https://raw.githubusercontent.com/Libertech-FR/sesame-gestion-mdp/main/src/public/img/background.png" --output config/img/background.png
  curl -L "https://raw.githubusercontent.com/Libertech-FR/sesame-gestion-mdp/main/src/public/img/logo.png" --output config/img/logo.png
  curl -L "https://raw.githubusercontent.com/Libertech-FR/sesame-gestion-mdp/main/src/public/favicon.ico" --output config/favicon.ico
fi
echo ""
echo "L'installation est terminée. Vous pouvez lancer le service #docker compose up -d"


