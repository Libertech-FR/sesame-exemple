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
read -p "Url du serveur (http(s)://(nom|ip):" HOST
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
#copy docker-compose.yml 
if [ ! -f "docker-compose.yml" ];then
	cp docker-compose.yml.example docker-compose.yml
fi
#creation des networks
docker network create sesame
docker network create reverse
docker pull mihaigalos/randompass
#docker compose up -d
KEY=`make sesame-generate-jwt-secret`
# Generation .env 
echo JWT_SECRET=\'$KEY\' >.env
echo HOST=$HOST >>.env
echo TLS=false >>.env
echo "Demarrage services"
docker compose pull
docker compose up -d
mkdir configs/sesame-taiga-crawler/cache
chown 10001 configs/sesame-taiga-crawler/cache
mkdir configs/sesame-taiga-crawler/data
chown 10001 configs/sesame-taiga-crawler/data
# installation compte admin 
echo "CREATION COMPTE ADMIN"
make sesame-create-agent
echo "INSTALL Import"
### Install Keying import
mkdir import 
mkdir import/cache 
mkdir import/data
chown 10001 import/data
chown 10001 import/cache
docker cp install/createImportKeyring.sh sesame-orchestrator:/tmp
docker exec -it sesame-orchestrator /tmp/createImportKeyring.sh >/tmp/key_taiga
echo "-------------------------------"
echo SESAME_API_BASEURL=http://sesame-orchestrator:4000 >import/.env
echo SESAME_IMPORT_PARALLELS_FILES=1 >>import/.env
echo SESAME_IMPORT_PARALLELS_ENTRIES=5 >>import/.env
echo SESAME_API_TOKEN=`cat /tmp/key_taiga` >>import/.env
rm -rf /tmp/key_taiga
echo "------------------------------"
echo "L'installation est terminée"
echo "Vous pouvez vous connecter à l interface via $HOST:3000"
echo "-----------------------------"
