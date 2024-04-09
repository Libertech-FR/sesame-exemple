
# Guide de démarrage - Application de Synchronisation d'Identités

## Sommaire

1. [Prérequis](#1-prérequis)
2. [Installation](#2-installation)
3. [Configuration](#3-configuration)
4. [Lancement](#4-lancement)
5. [Configuration du daemon (sans Docker)](#5-configuration-du-daemon-sans-docker)
6. [Utilisation](#6-utilisation)
7. [Maintenance](#7-maintenance)
8. [Aide et documentation](#8-aide-et-documentation)
9. [Annexe](#9-annexe)
10. [Conclusion](#10-conclusion)

## 1. Prérequis

- Docker
- Git
- Make

## 2. Installation

### Cloner le dépôt

```bash
git clone [URL_DU_REPO] sesame-project
cd sesame-project
```

### Configuration des environnements

- **sesame-orchestrator**:
  ```bash
  cp sesame-orchestrator/.env.example sesame-orchestrator/.env
  # Modifier le .env pour ajouter les configurations spécifiques
  ```
- **sesame-app-manager**:
  ```bash
  cp sesame-app-manager/.env.example sesame-app-manager/.env
  # Modifier le .env pour ajouter les configurations spécifiques
  ```

### Installation des dépendances

```bash
docker-compose build
```

## 3. Configuration

### Dossiers de configuration

Configurer les dossiers pour chaque service dans `configs/` en suivant les instructions spécifiques pour chaque module.

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

```bash
# Télécharger le paquet depuis GitHub en fonction de l'OS
wget [URL_DU_PAQUET] -O sesame-deamon.pkg
# Installer le paquet
sudo installer -pkg sesame-deamon.pkg -target /
```

## 6. Utilisation

### Accès à l'interface d'administration

Accéder à l'interface d'administration de `sesame-app-manager` via l'URL configurée pour voir l'interface et commencer à gérer les identités.

## 7. Maintenance

### Mises à jour et imports

```bash
make update
make import
```

## 8. Aide et documentation

Fournir des liens vers la documentation technique détaillée, des FAQs et des ressources d'aide en cas de problèmes.

## 9. Annexe

Inclure des annexes pour les configurations spécifiques, les scripts d'import ou les commandes de débogage.

## 10. Conclusion

Ce guide doit être accompagné d'un README détaillé, fournissant un aperçu rapide du projet, des liens vers la documentation complète, et les contacts pour le support technique.
