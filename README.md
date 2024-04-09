
# Guide de démarrage - Application de Synchronisation d'Identités

## Sommaire

- [Guide de démarrage - Application de Synchronisation d'Identités](#guide-de-démarrage---application-de-synchronisation-didentités)
  - [Sommaire](#sommaire)
  - [1. Prérequis](#1-prérequis)
  - [2. Installation](#2-installation)
    - [Arborescence du projet](#arborescence-du-projet)
    - [Configuration des environnements](#configuration-des-environnements)
  - [3. Configuration](#3-configuration)
    - [Dossiers de configuration](#dossiers-de-configuration)
  - [4. Lancement](#4-lancement)
    - [Démarrage des services](#démarrage-des-services)
    - [Vérification](#vérification)
  - [5. Configuration du daemon (sans Docker)](#5-configuration-du-daemon-sans-docker)
    - [Installation du daemon](#installation-du-daemon)
  - [6. Utilisation](#6-utilisation)
    - [Accès à l'interface d'administration](#accès-à-linterface-dadministration)
  - [8. Aide et documentation](#8-aide-et-documentation)
  - [9. Annexe](#9-annexe)
  - [10. Conclusion](#10-conclusion)

## 1. Prérequis

- Docker
- Git
- Make

## 2. Installation

### Arborescence du projet

```
docker-compose.yml
Makefile
configs/
├── sesame-app-manager/
│   ├── statics/
│   │   ├── logo.png
│   └── ...
└── sesame-orchestrator/
│   ├── jsonforms/
│   │   ├── nom_object_class.ui.yml
│   │   └── ...
│   └── validations/
│       ├── nom_object_class.yml
│       └── ...
└── sesame-taiga-crawler/
│   ├── .env
│   └── mappings.json
```

```bash    

```



### Configuration des environnements

//TODO

## 3. Configuration

### Dossiers de configuration

Configurer les dossiers pour chaque service dans `configs/` en suivant les instructions spécifiques pour chaque module.

//TODO

## 4. Lancement

### Démarrage des services

```bash
docker-compose up -d
```

### Vérification

```bash
docker-compose ps
```

## 5. Configuration du daemon (sans Docker)

### Installation du daemon

// TODO

## 6. Utilisation

### Accès à l'interface d'administration

Accéder à l'interface d'administration de `sesame-app-manager` via l'URL configurée pour voir l'interface et commencer à gérer les identités.

## 8. Aide et documentation

Fournir des liens vers la documentation technique détaillée, des FAQs et des ressources d'aide en cas de problèmes.

## 9. Annexe

Inclure des annexes pour les configurations spécifiques, les scripts d'import ou les commandes de débogage.

## 10. Conclusion

Ce guide doit être accompagné d'un README détaillé, fournissant un aperçu rapide du projet, des liens vers la documentation complète, et les contacts pour le support technique.
