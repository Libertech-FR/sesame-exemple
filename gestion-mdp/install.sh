#!/bin/bash
#set -x
#Verification si docker est installé
# test si le cpu supporte avx
cat /proc/cpuinfo|grep -i avx >/dev/null 2>/dev/null
OK=$?
if [ $OK = 1 ];then
  echo "le CPU doit avoir la fonctionnalité AVX"
  echo "Installaion impossible"
  exit 1
fi
type docker 2>/dev/null >/dev/null
OK=$?
if [ $OK = 1 ];then
	echo "Docker n'est pas installé, installez la"
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
curl -L 'https://raw.githubusercontent.com/Libertech-FR/sesame-exemple/main/gestion-mdp/docker-compose.yml' >docker-compose.yml
read -p "Url du serveur sesame-orchestrator (http(s)://(nom|ip):" HOST
# creation du reseau sesame
docker network create sesame
echo "Veuillez créer un jeton d'authentification sur sesame-orchestrator avec le commande : #make sesame-generate-jwt-secret"
read -p "Recopier ici le jeton généré par la commande ci-dessus :" JETON
echo "API_URL=$HOST" >.env
echo "API_KEY="$JETON"
echo "L'installation est terminée vous pouvez lancer le service #docker compose up -d"

