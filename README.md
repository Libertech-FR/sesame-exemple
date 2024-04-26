
# Guide de démarrage - Application de Synchronisation d'Identités

## Sommaire

- [Guide de démarrage - Application de Synchronisation d'Identités](#guide-de-démarrage---application-de-synchronisation-didentités)
  - [Sommaire](#sommaire)
  - [1. Prérequis](#1-prérequis)
  - [2. Installation](#2-installation)
    - [Arborescence du projet](#arborescence-du-projet)
  - [3. Configuration](#3-configuration)
    - [Sesame App Manager](#sesame-app-manager)
      - [Statics](#statics)
    - [Sesame Taiga Crawler](#sesame-taiga-crawler)
      - [.env](#env)
      - [mappings.json](#mappingsjson)
        - [Partie mapping](#partie-mapping)
        - [Partie additionalFields](#partie-additionalfields)
    - [Sesame Orchestrator](#sesame-orchestrator)
      - [validations](#validations)
      - [jsonforms](#jsonforms)
  - [4. Lancement](#4-lancement)
    - [Installation](#installation)
    - [Vérification](#vérification)
  - [5. Configuration du daemon (sans Docker)](#5-configuration-du-daemon-sans-docker)
    - [Installation du daemon](#installation-du-daemon)
  - [6. Utilisation](#6-utilisation)
    - [Accès à l'interface d'administration](#accès-à-linterface-dadministration)
  - [7. Aide et documentation](#7-aide-et-documentation)

## 1. Prérequis

- Docker [Installation](https://docs.docker.com/engine/install/)
- Avoir une machine avec un processeur qui supporte l'AVX
- Make

Installation de make :
- Pour Debian/Ubuntu :
```
apt install make
```
- Pour Alpine
```
apk add make
```

- Pour MacOs
```
brew install make
```

- Pour windows
```
choco install make
```

Ou installer directement les fichier [ici](https://gnuwin32.sourceforge.net/packages/make.htm)
## 2. Installation

### Téléchargement du repo

```bash
$ mkdir /data
$ cd /data
$ curl -L https://api.github.com/repos/Libertech-FR/sesame-exemple/tarball/main | tar -xz
```

### Vérification des prérequis et création du network
```bash
$ docker ps
# la commande doit foncitonner et par défaut si aucun conteneur n'à été lancer, retourner du vide

$ docker network create reverse
```

### Arborescence du projet
Pour utiliser Sesame, il est nécessaire de structurer l'arborescence comme il suit et de configurer les services nécessaires.

Des exemples des fichiers sont disponibles dans le repository [sesame-exemple](https://github.com/Libertech-FR/sesame-exemple)

```
docker-compose.yml
Makefile
configs/
├── sesame-app-manager/
│   ├── statics/
│   │   ├── logo.png
│   └── ...
├── sesame-orchestrator/
│   ├── jsonforms/
│   │   ├── nom_object_class.ui.yml
│   │   └── ...
│   └── validations/
│       ├── nom_object_class.yml
│       └── ...
├── sesame-taiga-crawler/
│   ├── .env
│   └── mappings.json
```

- `docker-compose.yml` : Fichier de configuration Docker Compose pour lancer les services.
- `Makefile` : Fichier de configuration Make pour lancer les commandes de gestion des services et l'import des identitées depuis taiga.
- `configs/` : Dossier de configuration pour chaque service.
  - `sesame-app-manager/` : Configuration de l'application de gestion des identités.
    - `statics/` : Dossier contenant les fichiers statiques (images, etc.).
  - `sesame-orchestrator/` : Configuration de l'orchestrateur.
    - `jsonforms/` : Dossier contenant les formulaires JSON pour les objets.
    - `validations/` : Dossier contenant les fichiers de validation des objets.
  - `sesame-taiga-crawler/` : Configuration du crawler Taiga.
    - `.env` : Fichier de configuration des variables d'environnement.
    - `mappings.json` : Fichier de configuration des mappings des objets pour l'import de Taiga vers Sesame.


## 3. Configuration

### Sesame App Manager

  Exemple de dossier : [ici](https://github.com/Libertech-FR/sesame-exemple/tree/main/configs/sesame-app-manager)
  #### Statics
  Exemple de dossier : [ici](https://github.com/Libertech-FR/sesame-exemple/tree/main/configs/sesame-app-manager/statics)
  - Ajouter les fichiers statiques (images, etc.) dans le dossier `configs/sesame-app-manager/statics/`.
  
      | Titre    | Description |
      | -------- | ------- |
      | logo.png  | Logo de l'organisation. |
      | login-background.png | Image de fond de la page de connexion. |
      | login-side.png | Image a gauche des champs de connexion. |

### Sesame Orchestrator
  Exemple de dossier : [ici](https://github.com/Libertech-FR/sesame-exemple/tree/main/configs/sesame-orchestrator)

  #### validations
  [Exemple de validations](https://github.com/Libertech-FR/sesame-exemple/tree/main/configs/sesame-orchestrator/validations)

  [Exemple de fichier de validation](https://github.com/Libertech-FR/sesame-exemple/blob/main/configs/sesame-orchestrator/validations/supann.yml)

  Ajouter les fichiers de validation des objets dans le dossier `configs/sesame-orchestrator/validations/`.

  Créer un fichier de validation pour chaque objet à importer. Les fichiers de validation sont des fichiers YAML qui définissent les règles de validation des objets. Les fichiers de validation sont utilisés par l'orchestrateur pour valider les objets avant de les importer dans la base de données et pour valider des modifications dans l'interface.

  Bien nommer les fichiers de validation pour qu'ils correspondent aux noms des objets à importer. Par exemple, pour un objet `Person`, nommer le fichier `person.yml`

  Pour plus de details sur le fichier merci de suivre cette documentation : [Validation d'identité](https://libertech-fr.github.io/sesame-orchestrator/additional-documentation/documentation-utilisateur/validation-des-schemas-compl%C3%A9mentaires-de-l'identit%C3%A9.html)

  #### jsonforms

  [Exemple de jsonforms](https://github.com/Libertech-FR/sesame-exemple/tree/main/configs/sesame-orchestrator/jsonforms)

  [Exemple de fichier de formulaire](https://github.com/Libertech-FR/sesame-exemple/blob/main/configs/sesame-orchestrator/jsonforms/supann.ui.yml)
  
  Ajouter les formulaires JSON pour les objets dans le dossier `configs/sesame-orchestrator/jsonforms/`. Ces formulaires serront utilisé par la librairie [jsonforms](https://jsonforms.io/docs/uischema) pour générer les formulaires de création et de modification des objets dans l'interface.

  Ici deux solutions, soit vous devez créer un fichier pour chaque objet que vous voulez importer, avec la convention suivante : `nom_object_class.ui.yml`. Par exemple, pour un objet `Person`, nommer le fichier `person.ui.yml`.

  Soit vous pouvez utiliser la commande `make generate-jsonforms` pour générer automatiquement les formulaires pour tous les objets à partir des fichiers de validation. Pour cela, il faut que les fichiers de validation soient déjà présents dans le dossier `configs/sesame-orchestrator/validations/`.

### Sesame Taiga Crawler (optionnel)
  Exemple de dossier : [ici](https://github.com/Libertech-FR/sesame-exemple/tree/main/configs/sesame-taiga-crawler)

  #### .env
  [Exemple de .env](https://github.com/Libertech-FR/sesame-exemple/blob/main/configs/sesame-taiga-crawler/.env)

  - Configurer les variables d'environnement dans le fichier `configs/sesame-taiga-crawler/.env`.
  
    | Variable | Description |
    | -------- | ------- |
    | STC_API_BASEURL | URL de l'API Taiga. |
    | STC_API_USERNAME | Nom d'utilisateur de l'API Taiga. |
    | STC_API_PASSWORD | Mot de passe de l'API Taiga. |
    | STC_API_FORWARD_PORT | Port de redirection pour l'API Taiga. |
    | STC_API_PASSENSA | Mot de passe de l'ENSA. |
    | SESAME_API_BASEURL | URL de l'API Sesame Orchestrator. |

  #### mappings.json
  [Exemple de mappings.json](https://github.com/Libertech-FR/sesame-exemple/blob/main/configs/sesame-taiga-crawler/mapping.json)
  - Configurer les mappings des objets pour l'import de Taiga vers Sesame dans le fichier `configs/sesame-taiga-crawler/mappings.json`. L'application utilise la librairie python [DataWeaver](https://github.com/RICHARD-Quentin/DataWeaver/blob/main/README.md#configuration) dont voici un extrait de la documentation pour la configuration des mappings :
  
  Dans le cas de taiga, le script va consommer l'API de taiga et récupérer les données des identités. Il les stockera ensuite dans différents fichier JSON selon leur affecation: taiga_etd.json, taiga_ens.json, taiga_adm.json. Ces fichiers seront ensuite utilisés par l'orchestrateur pour les importer dans la base de données. Il faudra structurer le fichier de la manière suivante :
  
  ```json
  /// mapping.json
  {
    "taiga_etd.json": {
      "mapping": {
        ...
      },
      "additionalFields": {
        ...
      }
    },
    "taiga_ens.json": {
      "mapping": {
        ...
      },
      "additionalFields": {
        ...
      }
    },
    "taiga_adm.json": {
      "mapping": {
        ...
      },
      "additionalFields": {
        ...
      }
    }
  }
  ```

##### Partie mapping
  Les champs de mapping sont les champs de l'objet à importer. Les clés sont les champs de l'objet à importer et les valeurs sont les champs de l'objet source. Les champs de l'objet source sont des expressions régulières qui permettent de récupérer les données de l'objet source. Les champs de l'objet à importer sont des expressions régulières qui permettent de formater les données récupérées de l'objet source.

Dans notre cas, il faudra structurer ces deux parties comme il suit :
- Pour les champs inetOrgPerson, la clé devra etre le nom de la valeur venant de taiga que l'on veut maper et sa valeur devra commencer par inetOrgPerson puis le nom du champ que l'on veut mapper inetOrgPerson.nom_du_champ_sesame ,  par exemple : 

```json
"mapping": {
  "inetOrgPerson.cn": "nom",
}
```

- Pour tout les autres champs qui dependent de schema additionels, de la même manière il faudra que la clé soit le nom de la valeur venant de taiga que l'on veut maper et sa valeur devra commencer par le nom du schema puis le nom du champ que l'on veut mapper additionalFields.attributes.nom_du_schema.nom_du_champ_sesame ,  par exemple : 

```json
"mapping": {
  "additionalFields.attributes.supann.nom": "nom",
}

```

##### Partie additionalFields
Les champs additionnels sont des champs qui ne sont pas présents dans l'objet source mais qui sont nécessaires pour l'import de l'objet. Les clés sont les champs de l'objet à importer et les valeurs sont des valeurs qui serront attribué a la clé.

Certains champs sont requis pour la creation d'un objet dans la base de données, il faudra donc les ajouter dans le fichier de configuration. Les champs requies sont les suivants :
  - `additionalFields.objectClasses` : un tableau avec la liste des champs additionel que l'on veut ajouter a notre identité, par exemple :
  ```json 
  "additionalFields": {
    "additionalFields.objectClasses": ["supann"]
  }
  
  ```
  - `additionalFields.state` : le status de l'identité, -1 pour une creation/update par exemple :
  ```json
  "additionalFields": {
    "state": -1
  }
  ```

  Dans cette partie nous pouvons aussi ajouter des champs additionels qui ne sont pas present dans l'objet source, par exemple : 
  ```json
  "additionalFields": {
    "additionalFields.attributes.supann.supannTypeEntiteAffectation": "etd",
  }
  ```

  Pour toute operation sur les champs, il est possible d'ajouter une fonction de transformation descrite dans la documentation de [DataWeaver Transformations](https://github.com/RICHARD-Quentin/DataWeaver/blob/main/README.md#configuration-file-transforms)
## 4. Lancement

Pour toute les operations de lancement, de mise a jours ou de build, il est necessaire d'utiliser le fichier `docker-compose.yml`. Certaines commandes sont aussi disponible dans le fichier `Makefile` pour simplifier les operations.

### Installation
Copier le fichier `docker-compose.yml` de ce repository [disponible ici](https://github.com/Libertech-FR/sesame-exemple/blob/main/docker-compose.yml)  à la racine du projet et faculativement le fichier `Makefile` [disponible ici](https://github.com/Libertech-FR/sesame-exemple/blob/main/Makefile) à la racine du projet.

Si vous utilisez le fichier `Makefile`, vous pouvez lancer les commandes suivantes :
  
  ```bash
  make sesame-generate-jwt-secret
  ```
Sinon lancer la commande 
  ```bash
  docker run --rm mihaigalos/randompass --length 32
  ```
Et copier le resultat.

Dans le `docker-compose.yml`, dans le service `sesame-orchestrator`, dans la partie `environment`, modifier la variable SESAME_JWT_SECRET avec le resultat de la commande précédente.

Modifier egalement dans le docker compose les variables suivantes : 
- `<public_url_orchestrator>`: remplacer par ip_de_votre_machine:4000 ou le nom de domaine associé a la machine dans la partie `sesame-orchestrator.environment` et `sesame-app-manager.labels`
- `<public_url_app_manager>`: remplacer par ip_de_votre_machine:3000 ou le nom de domaine associé a la machine dans la partie `sesame-orchestrator.labels`

Pour lancer les services la première fois et par la suite pour mettre a jours, exécuter la commande suivante :

```bash
docker compose pull
docker compose up -d
```

Ou avec le `Makefile` :

```bash
make sesame-update
```

#### Création du compte admin 

```bash
make sesame-create-agent
```

ou

```bash
docker exec -it sesame-orchestrator \
  yarn console agents create
```


#### Creation d'un jeton d'authentification pour un script d'import

```bash
make sesame-create-keyring
```

ou

```bash
docker exec -it sesame-orchestrator \
  yarn console keyrings create
```

Pour lancer l'import des identités depuis Taiga, exécuter la commande suivante :


```bash
docker run ghcr.io/libertech-fr/sesame-taiga_crawler:latest \
  -v $(PWD)/configs/sesame-taiga-crawler:/app/configs
  --network sesame
```

Ou avec le `Makefile` :

```bash
make sesame-import-taiga
```

### Vérification

```bash
docker compose ps
```

## 5. Configuration du daemon (sans Docker)

### Installation du daemon

// TODO

## 6. Utilisation

### Accès à l'interface d'administration

Accéder à l'interface d'administration de `sesame-app-manager` via l'URL configurée pour voir l'interface et commencer à gérer les identités.

## 7. Aide et documentation

- [Documentation technique](https://libertech-fr.github.io/sesame-orchestrator/additional-documentation/documentation-technique.html)
- [Documentation utilisateur](https://libertech-fr.github.io/sesame-orchestrator/additional-documentation/documentation-utilisateur.html)
- [DataWeaver](https://github.com/RICHARD-Quentin/DataWeaver/blob/main/README.md)
- [JSONForms](https://jsonforms.io/docs/uischema)
