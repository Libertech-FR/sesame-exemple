#!/bin/bash
read -p "IP du serveur : " IP
read -p "Nom du serveur (FDQN) : " FDQN
echo "Generation du certificat "
#Generation fichier cnf
cat <<THEEND >/tmp/san.cnf
[req]
default_bits       = 2048
default_keyfile    = localhost.key
distinguished_name = req_distinguished_name
req_extensions     = req_ext
x509_extensions    = v3_ca
prompt = no
[req_distinguished_name]
C=FR
ST=FRANCE
O=SESAME
OU=SELF-CERTIFICATE
CN=$FDQN

[req_ext]
subjectAltName = @alt_names

[v3_ca]
subjectAltName = @alt_names

[alt_names]
DNS.1   = $FDQN
IP.1    = $IP

THEEND
cat /tmp/san.cnf | envsubst >/tmp/ssl.cnf
rm -rf /tmp/san.cnf
#creation du repertoire
mkdir ./certificates 2>/dev/null
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout certificates/server.key -out certificates/server.crt -config /tmp/ssl.cnf >/dev/null

