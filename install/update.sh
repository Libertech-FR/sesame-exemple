#!/bin/bash 
#set -x
#Verification si docker est installé
# test si le cpu supporte avx
MYPWD=`pwd`
cd /tmp   
rm -rf Libertech-FR-sesame*
curl -L https://api.github.com/repos/Libertech-FR/sesame-exemple/tarball/main | tar -xz
cd Libertech-FR-sesame*
cp Makefile $MYPWD
cp utils/* $MYPWD/utils
cp install/* $MYPWD/install
mkdir import  2>/dev/null
mkdir import/cache 2>/dev/null 
mkdir import/data 2>/dev/null
chown 10001 import/data
chown 10001 import/cache

