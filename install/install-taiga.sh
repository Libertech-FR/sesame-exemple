#!/bin/bash
echo "Parametres de connexion à TAIGA"
echo "-------------------------------"
read -e -p "URL TAIGA (https://taiga.archi.fr) :" -i https://taiga.archi.fr URL_TAIGA
read -p "UTILISATEUR TAIGA :" USER_TAIGA
read -p "MOT DE PASSE : " PASSWORD_TAIGA  
read -p "Code Ensa : " CODEENSA
read -p "MOT DE PAS ENSA : " PASSWORD_ENSA
#GEneration du token 
mkdir configs/sesame-taiga-crawler/cache 
chown 10001 configs/sesame-taiga-crawler/cache
mkdir configs/sesame-taiga-crawler/data
chown 10001 configs/sesame-taiga-crawler/data
docker cp install/createTargaKeyring.sh sesame-orchestrator:/tmp

docker exec -it sesame-orchestrator /tmp/createTargaKeyring.sh >/tmp/key_taiga

echo SESAME_API_BASEURL=http://sesame-orchestrator:4000 >configs/sesame-taiga-crawler/.env
echo SESAME_IMPORT_PARALLELS_FILES=1 >>configs/sesame-taiga-crawler/.env
echo SESAME_IMPORT_PARALLELS_ENTRIES=5 >>configs/sesame-taiga-crawler/.env
echo STC_API_BASEURL=${URL_TAIGA} >>configs/sesame-taiga-crawler/.env
echo STC_API_CODEENSA=${CODEENSA} >>configs/sesame-taiga-crawler/.env
echo STC_API_USERNAME=${USER_TAIGA} >>configs/sesame-taiga-crawler/.env
echo STC_API_PASSWORD=${PASSWORD_TAIGA} >>configs/sesame-taiga-crawler/.env
echo STC_API_PASSENSA=${PASSWORD_ENSA} >>configs/sesame-taiga-crawler/.env
echo SESAME_API_TOKEN=`cat /tmp/key_taiga` >>configs/sesame-taiga-crawler/.env
#generation config.yml
cat configs/sesame-taiga-crawler/config.tmpl |envsubst '${DOMAIN} ${SUPANET}' >configs/sesame-taiga-crawler/config.yml
echo "-----------------------------"
echo "Pour lancer l'importation taiga dans le repertoire $mypwd lancez la commande make sesame-import-taiga"
echo "-----------------------------"
