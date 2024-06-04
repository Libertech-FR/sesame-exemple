# Installation de sesame-daemon

## Introduction 

**Sesame-Daemon** fait la communication entre sesame-Orchestrateur et les differents catalogues et bases de données d'authentification. 

**Sesame-Daemon** executera chaque **backend** quand il recevera un ordre de sesame-Orchestrateur

## Prérequis 
* Debian 12 

Malgrés que le daemon peut être sur une autre machine que l'orchestrator nous vous conseillons, pour des raisons de sécurité et facilité de l'installer sur le meme host

## Installation du démon 

Pour l'instant l'installation n'est disponible que pour **Debian** 

Télécharger le package debian : 

[Lien de téléchargement du paquet (https://github.com/Libertech-FR/sesame-daemon/releases)](https://github.com/Libertech-FR/sesame-daemon/releases/)

Assurez vous avant de lancer l'installation que sesame est bien démarré

```
#apt-get update 
#dpkg -i sesame-daemon_0.2.13_amd64.deb 
Sélection du paquet sesame-daemon précédemment désélectionné.
(Lecture de la base de données... 37026 fichiers et répertoires déjà installés.)
Préparation du dépaquetage de sesame-daemon_0.2.13_amd64.deb ...
Dépaquetage de sesame-daemon (0.2.13) ...
Paramétrage de sesame-daemon (0.2.13) ...
Created symlink /etc/systemd/system/multi-user.target.wants/sesame-daemon.service → /lib/systemd/system/sesame-daemon.service.
```

Vérifier que le daemon est bien démarré

```
#journalctl -u sesame-daemon
juin 04 18:11:29 docker2 systemd[1]: Stopping sesame-daemon.service - sesame-daemon...
juin 04 18:11:29 docker2 systemd[1]: sesame-daemon.service: Deactivated successfully.
juin 04 18:11:29 docker2 systemd[1]: Stopped sesame-daemon.service - sesame-daemon.
juin 04 18:11:29 docker2 systemd[1]: sesame-daemon.service: Consumed 1.413s CPU time.
juin 04 18:11:29 docker2 systemd[1]: Started sesame-daemon.service - sesame-daemon.
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [NestFactory] Starting Nest application...
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [InstanceLoader] RedisModule dependencies initiali>
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [InstanceLoader] AppModule dependencies initialize>
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [InstanceLoader] ConfigHostModule dependencies ini>
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [InstanceLoader] ConfigModule dependencies initial>
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [InstanceLoader] ConfigModule dependencies initial>
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [InstanceLoader] RedisCoreModule dependencies init>
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [InstanceLoader] BackendRunnerModule dependencies >
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [BackendRunnerService] OnModuleInit initialized 🔴
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [BackendConfigService] Load backends config...
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [BackendConfigService] /var/lib/sesame-daemon/back>
juin 04 18:11:30 docker2 sesame-daemon[975938]: [Nest] 975938  - 2024-06-04 18:11:30     LOG [BackendRunnerService] OnApplicationBootstrap init>
```

## Installation du backend LDAP 

télechargez le paquet debian (.deb) avec ce lien 

[https://github.com/Libertech-FR/sesame-backend-ldap/releases](https://github.com/Libertech-FR/sesame-backend-ldap/releases/)

```
# dpkg -i sesame-backend-openldap_0.0.3_amd64.deb 
Sélection du paquet sesame-backend-openldap précédemment désélectionné.
(Lecture de la base de données... 37052 fichiers et répertoires déjà installés.)
Préparation du dépaquetage de sesame-backend-openldap_0.0.3_amd64.deb ...
Dépaquetage de sesame-backend-openldap (0.0.3) ...
dpkg: des problèmes de dépendances empêchent la configuration de sesame-backend-openldap :
 sesame-backend-openldap dépend de libnet-ldap-perl; cependant :
  Le paquet libnet-ldap-perl n'est pas installé.
 sesame-backend-openldap dépend de libjson-perl; cependant :
  Le paquet libjson-perl n'est pas installé.

dpkg: erreur de traitement du paquet sesame-backend-openldap (--install) :
 problèmes de dépendances - laissé non configuré
Des erreurs ont été rencontrées pendant l'exécution :
 sesame-backend-openldap
```
Ces erreurs sont normales car dpkg n'installe pas les dépendance tout seul.

Installez les dépendances : 

```
#apt-get -f install
```

## Configuration du backend LDAP 






