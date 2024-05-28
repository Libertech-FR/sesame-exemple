#!/bin/bash 
set -x
#Verification si docker est installé
type docker 2>/dev/null >/dev/null
OK=$?
if [ $OK = 1 ];then
	echo "la commande make n'est pas installée, installez la"
        exit 1
else
	echo "Commande docker OK"
fi    
#Verification si make est installé
type make 2>/dev/null >/dev/null
OK=$?
if [ $OK = 1 ];then
	echo "la commande make n'est pas installée, installez la"
        exit 1
else
        echo "command make OK"
fi 
#Verification si curl est installé
type curl 2>/dev/null >/dev/null
OK=$?
if [ $OK = 1 ];then
	echo "la commande curl n'est pas installée, installez la"
        exit 1
else
        echo "command curl OK"
fi 
PWD=`pwd`
read -p "Répertoire d'installation ($PWD) :" mypwd   
read -p "Ip ou nom du serveur :" HOST
echo $mypwd
if [ "$mypwd" = "" ];then 
	mypwd=$PWD
fi
echo "Installation dans $mypwd"
if [ ! -d "$mypwd" ];then
	echo "Vous devez creer le repertoire $mypwd"
	exit 1;
fi

cd /tmp   
rm -rf Libertech-FR-sesame*
curl -L https://api.github.com/repos/Libertech-FR/sesame-exemple/tarball/main | tar -xz
cd Libertech-FR-sesame*
find .|cpio -pdvum $mypwd
cd $mypwd
#creation des networks
docker network create sesame
docker network create reverse
docker pull mihaigalos/randompass
docker compose pull
#docker compose up -d
KEY=`make sesame-generate-jwt-secret`
# Generation .env 
echo JWT_SECRET=$KEY >.env
echo HOST=$HOST >>.env
echo TLS=false >>.env
echo "Demarrage services"
docker compose up -d
# installation compte admin 
echo "CREATION COMPTE ADMIN"
make sesame-create-agent
### Install Keying Taiga
docker cp install/createTargaKeyring.sh sesame-orchestrator:/tmp
docker exec -it sesame-orchestrator /tmp/createTargaKeyring.sh >/tmp/key_taiga
read -e -p "URL TAIGA (https://taiga.archi.fr) :" -i https://taiga.archi.fr URL_TAIGA
read -e -p "PORT (443) : " -i 443  PORT_TAIGA
read -p "UTILISATEUR TAIGA :" USER_TAIGA
read -p "MOT DE PASSE : " PASSWORD_TAIGA 
read -p "MOT DE PAS ENSA : " PASSWORD_ENSA
echo SESAME_API_BASEURL=http://sesame-orchestrator:4000 >configs/sesame-taiga-crawler/.env
echo SESAME_IMPORT_PARALLELS_FILES=1 >>configs/sesame-taiga-crawler/.env
echo SESAME_IMPORT_PARALLELS_ENTRIES=5 >>configs/sesame-taiga-crawler/.env
echo STC_API_BASEURL=${URL_TAIGA} >>configs/sesame-taiga-crawler/.env            
echo STC_API_USERNAME=${USER_TAIGA} >>configs/sesame-taiga-crawler/.env
echo STC_API_PASSWORD=${PASSWORD_TAIGA} >>configs/sesame-taiga-crawler/.env
echo STC_API_FORWARD_PORT=${PORT_TAIGA} >>configs/sesame-taiga-crawler/.env
echo STC_API_PASSENSA=${PASSWORD_ENSA} >>configs/sesame-taiga-crawler/.env
echo SESAME_API_TOKEN=`cat /tmp/key_taiga` >>configs/sesame-taiga-crawler/.env
rm -rf /tmp/key_taiga
