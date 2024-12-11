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
mkdir ./certs
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout certs/key.pem -out certs/cert.pem -config /tmp/ssl.cnf >/dev/null

echo "GEneration de la configuration nginx"
mkdir templates
cat <<THEEND1 >templates/ssl.conf.template
ssl_session_timeout 1d;
ssl_session_cache shared:MozSSL:10m;  # about 40000 sessions
ssl_session_tickets off;
#ssl_dhparam /etc/cert/dhparam.pem;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128i-GCM-SHA256DHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;
add_header Strict-Transport-Security "max-age=63072000" always;
ssl_stapling on;
ssl_stapling_verify on;
ssl_certificate /etc/certs/cert.pem;
ssl_certificate_key /etc/certs/key.pem;
THEEND1
# Generation header.conf
cat <<THEEND2 >templates/header.conf.template
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block" always ;
add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";
THEEND2
cat <<THEEND3 >templates/default.conf.template
server {
    listen       80;
    server_name  $FDQN;
    return 301 https://\$host\$request_uri;
}
server {
  listen 443 ssl;
  server_name $FDQN;
  location / {
      set \$upstream "site_sesame_manager";
      expires off;
      proxy_pass http://sesame-app-manager:3000;
    }
   proxy_set_header X-Real-IP \$remote_addr;
   proxy_set_header Host \$host;
   proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
   
}
server {
  listen 4000 ssl;
  server_name localhost;
  location / {
      set \$upstream "site_sesame_orchestrator";
      expires off;
      proxy_pass http://sesame-orchestrator:4000;
    }
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header Host \$host;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
}
upstream site_sesame_manager{
        server sesame-app-manager;
}
upstream site_sesame_orchestrator{
        server sesame-orchestrator;
}
access_log   /var/log/nginx/sesame.log;
error_log    /var/log/nginx/sesame_err.log;
THEEND3
# Generation docker compose
cat <<THEEND4 >./docker-compose.yml
services:
  revproxy:
    image: nginx
    container_name: revproxy
    volumes:
      - ./log:/var/log/nginx
      - ./templates:/etc/nginx/templates
      - ./certs:/etc/certs
    ports:
      - "443:443"
      - "80:80"
      - "4000:4000"
    networks:
      - reverse
    restart: always
networks:
  reverse:
    external: true
THEEND4
