#!/usr/bin/env python3
"""
Script d'upgrade vers SESAME v2

Ce script migre la configuration de v1 à v2 où:
- sesame-app-manager est supprimé et intégré dans sesame-orchestrator
- Les volumes changent: ./apps/web (app-manager) et ./apps/api (orchestrator)
  qui sont montés vers /data/apps/web et /data/apps/api dans le conteneur
- Les ports restent identiques mais se déplacent dans orchestrator
"""

import os
import sys
import re
import shutil
import subprocess
import time
from pathlib import Path

# Couleurs pour l'output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    NC = '\033[0m'  # No Color

def log_info(message):
    print(f"{Colors.GREEN}[INFO]{Colors.NC} {message}")

def log_warn(message):
    print(f"{Colors.YELLOW}[WARN]{Colors.NC} {message}")

def log_error(message):
    print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")

def run_command(command, ignore_error=False, verbose=True):
    """Exécute une commande shell"""
    try:
        if verbose:
            # Mode verbose: afficher la sortie en temps réel
            result = subprocess.run(command, shell=True, text=True)
            return result.returncode == 0
        else:
            # Mode normal: capturer la sortie
            result = subprocess.run(command, shell=True, capture_output=True, text=True)
            if result.returncode != 0 and not ignore_error:
                log_warn(f"Commande a échoué: {command}")
                if result.stderr:
                    print(result.stderr)
            return result.returncode == 0
    except Exception as e:
        if not ignore_error:
            log_error(f"Erreur lors de l'exécution de: {command}")
            log_error(str(e))
        return False

def main():
    print("=" * 50)
    print("SESAME - Upgrade to v2")
    print("=" * 50)
    print()

    # Changer vers le répertoire du script
    script_dir = Path(__file__).parent.absolute()
    os.chdir(script_dir)
    
    # Vérifier que docker-compose.yml existe
    if not Path("docker-compose.yml").exists():
        log_error("docker-compose.yml n'existe pas!")
        sys.exit(1)

    # Vérifier si une sauvegarde existe déjà
    backup_file = Path("docker-compose.yml.v1.backup")
    if backup_file.exists():
        log_warn("Une sauvegarde v1 existe déjà (docker-compose.yml.v1.backup)")
        response = input("Voulez-vous continuer et l'écraser? (y/N): ")
        if response.lower() not in ['y', 'yes']:
            log_info("Upgrade annulé")
            sys.exit(0)

    # Étape 1: Dump de la base de données
    log_info("Étape 1/8: Sauvegarde de la base de données (make sesame-dump)...")
    if not run_command("make sesame-dump", ignore_error=True, verbose=True):
        log_warn("Le dump de la base de données a échoué ou n'était pas possible")
        response = input("Voulez-vous continuer malgré tout? (y/N): ")
        if response.lower() not in ['y', 'yes']:
            log_info("Upgrade annulé")
            sys.exit(0)
    else:
        log_info("✓ Dump de la base de données effectué")

    time.sleep(1)

    # Étape 2: Arrêt des conteneurs
    log_info("Étape 2/8: Arrêt des conteneurs existants...")
    if not run_command("docker-compose down", ignore_error=True):
        log_warn("Échec de l'arrêt des conteneurs (peut-être déjà arrêtés)")
    
    # Vérifier que les conteneurs sont bien arrêtés
    log_info("Vérification que les conteneurs applicatifs sont arrêtés...")
    result = subprocess.run(
        "docker ps --filter name=sesame- --format '{{.Names}}'",
        shell=True,
        capture_output=True,
        text=True
    )
    
    if result.stdout.strip():
        # Filtrer pour exclure les conteneurs de base de données (mongo, redis)
        running_containers = [
            container for container in result.stdout.strip().split('\n')
            if container and 'mongo' not in container.lower() and 'redis' not in container.lower()
        ]
        
        if running_containers:
            log_error("Les conteneurs applicatifs suivants sont encore en cours d'exécution:")
            for container in running_containers:
                print(f"  - {container}")
            log_error("Veuillez arrêter manuellement les conteneurs avant de continuer")
            sys.exit(1)
    
    log_info("✓ Tous les conteneurs applicatifs Sesame sont arrêtés")

    time.sleep(1)

    # Étape 3: Sauvegarde du docker-compose.yml
    log_info("Étape 3/8: Sauvegarde du docker-compose.yml actuel...")
    shutil.copy2("docker-compose.yml", "docker-compose.yml.v1.backup")
    log_info("Sauvegarde créée: docker-compose.yml.v1.backup")

    time.sleep(1)

    # Étape 4: Vérification de la structure existante
    log_info("Étape 4/8: Vérification de la structure configs/ existante...")
    
    app_manager_src = Path("configs/sesame-app-manager")
    orchestrator_src = Path("configs/sesame-orchestrator")
    
    if not app_manager_src.exists():
        log_warn("Répertoire configs/sesame-app-manager introuvable")
    else:
        log_info(f"✓ configs/sesame-app-manager trouvé")
        
    if not orchestrator_src.exists():
        log_warn("Répertoire configs/sesame-orchestrator introuvable")
    else:
        log_info(f"✓ configs/sesame-orchestrator trouvé")

    time.sleep(1)

    # Étape 5: Pas de migration nécessaire - on garde les configs/ tels quels
    log_info("Étape 5/8: Les configurations restent dans configs/ (pas de migration)")
    log_info("Seuls les mappings de volumes seront modifiés dans docker-compose.yml")

    time.sleep(1)

    # Étape 6: Modification du docker-compose.yml
    log_info("Étape 6/8: Modification du docker-compose.yml...")

    with open('docker-compose.yml', 'r') as f:
        content = f.read()

    # Supprimer complètement le service sesame-app-manager
    app_manager_pattern = r'  sesame-app-manager:.*?(?=\n  [a-z]|\nnetworks:|\Z)'
    content = re.sub(app_manager_pattern, '', content, flags=re.DOTALL)

    # Ajouter le port 3333:3000 dans sesame-orchestrator si pas déjà présent
    ports_pattern = r'(  sesame-orchestrator:.*?ports:\s*\n)(.*?)(    depends_on:)'
    def add_port(match):
        orchestrator_start = match.group(1)
        existing_ports = match.group(2)
        depends_on = match.group(3)
        
        if '3333:3000' not in existing_ports:
            return orchestrator_start + '      - "3333:3000"\n' + existing_ports + depends_on
        return match.group(0)

    content = re.sub(ports_pattern, add_port, content, flags=re.DOTALL)

    # Ajouter SESAME_APP_API_URL dans environment de sesame-orchestrator si pas déjà présent
    env_pattern = r'(  sesame-orchestrator:.*?environment:\s*\n)(.*?)(    volumes:)'
    def add_env_var(match):
        orchestrator_start = match.group(1)
        existing_env = match.group(2)
        volumes = match.group(3)
        
        # Ajouter SESAME_APP_API_URL si pas présent
        if 'SESAME_APP_API_URL' not in existing_env:
            # Ajouter après les autres variables d'environnement
            lines = existing_env.rstrip('\n').split('\n')
            lines.append('      - SESAME_APP_API_URL=${HOST_PREFIX}:4000')
            new_env = '\n'.join(lines) + '\n'
            return orchestrator_start + new_env + volumes
        return match.group(0)

    content = re.sub(env_pattern, add_env_var, content, flags=re.DOTALL)

    # Remplacer les volumes de sesame-orchestrator
    volumes_pattern = r'(  sesame-orchestrator:.*?volumes:\s*\n)(.*?)(    networks:)'
    
    # Lister les sous-dossiers réels de configs/sesame-orchestrator et sesame-app-manager
    api_dirs = []
    web_dirs = []
    
    orchestrator_config = Path("configs/sesame-orchestrator")
    if orchestrator_config.exists():
        api_dirs = [d.name for d in orchestrator_config.iterdir() if d.is_dir()]
    
    app_manager_config = Path("configs/sesame-app-manager")
    if app_manager_config.exists():
        web_dirs = [d.name for d in app_manager_config.iterdir() if d.is_dir()]
    
    def replace_volumes(match):
        orchestrator_start = match.group(1)
        networks = match.group(3)
        
        volumes_lines = []
        
        # Ajouter les volumes pour l'API (orchestrator) basés sur les dossiers réels
        # Cas spéciaux:
        # - jsonforms et validations vont dans configs/identities/
        # - templates et storage vont à la racine /data/apps/api/
        # - mail-templates est ignoré
        if api_dirs:
            volumes_lines.append("      # Volumes pour l'orchestrator (API) - montés vers /data/apps/api/configs dans le conteneur")
            for dir_name in sorted(api_dirs):
                if dir_name == 'mail-templates':
                    # Ignorer mail-templates
                    continue
                elif dir_name in ['jsonforms', 'validations']:
                    # Ces dossiers vont dans configs/identities/
                    volumes_lines.append(f"      - ./configs/sesame-orchestrator/{dir_name}:/data/apps/api/configs/identities/{dir_name}")
                elif dir_name in ['templates', 'storage']:
                    # Ces dossiers vont directement à la racine /data/apps/api/
                    volumes_lines.append(f"      - ./configs/sesame-orchestrator/{dir_name}:/data/apps/api/{dir_name}")
                else:
                    # Les autres dossiers vont dans configs/
                    volumes_lines.append(f"      - ./configs/sesame-orchestrator/{dir_name}:/data/apps/api/configs/{dir_name}")
        
        # Ajouter les volumes pour le WEB (app-manager) basés sur les dossiers réels
        # Sur l'hôte: ./configs/sesame-app-manager/XXX → Dans le conteneur: /data/apps/web/...
        # Cas spéciaux:
        # - statics va dans /data/apps/web/src/public/config
        # - config va dans /data/apps/web/config
        if web_dirs:
            volumes_lines.append("      # Volumes pour l'app-manager (WEB) - montés vers /data/apps/web dans le conteneur")
            for dir_name in sorted(web_dirs):
                if dir_name == 'statics':
                    volumes_lines.append(f"      - ./configs/sesame-app-manager/{dir_name}:/data/apps/web/src/public/config")
                elif dir_name == 'config':
                    volumes_lines.append(f"      - ./configs/sesame-app-manager/{dir_name}:/data/apps/web/config")
                else:
                    # Autres dossiers vont dans /data/apps/web/config/{nom}
                    volumes_lines.append(f"      - ./configs/sesame-app-manager/{dir_name}:/data/apps/web/config/{dir_name}")
        
        # Ajouter les certificats
        volumes_lines.append("      # Certificates")
        volumes_lines.append("      - ./certificates:/data/certificates")
        
        new_volumes = '\n'.join(volumes_lines) + '\n'
        
        return orchestrator_start + new_volumes + networks

    content = re.sub(volumes_pattern, replace_volumes, content, flags=re.DOTALL)

    # Écrire le fichier modifié
    with open('docker-compose.yml', 'w') as f:
        f.write(content)

    log_info("docker-compose.yml v2 mis à jour!")

    time.sleep(1)

    # Étape 7: Vérification
    log_info("Étape 7/8: Vérification de la configuration...")
    print()
    print("Mappings de volumes configurés:")
    print("  Sur l'hôte                                    → Dans le conteneur")
    print("  " + "─" * 80)
    if orchestrator_src.exists():
        for dir_name in sorted([d.name for d in orchestrator_src.iterdir() if d.is_dir()]):
            if dir_name == 'mail-templates':
                print(f"  ./configs/sesame-orchestrator/{dir_name:<20} → (ignoré)")
            elif dir_name in ['jsonforms', 'validations']:
                print(f"  ./configs/sesame-orchestrator/{dir_name:<20} → /data/apps/api/configs/identities/{dir_name}")
            elif dir_name in ['templates', 'storage']:
                print(f"  ./configs/sesame-orchestrator/{dir_name:<20} → /data/apps/api/{dir_name}")
            else:
                print(f"  ./configs/sesame-orchestrator/{dir_name:<20} → /data/apps/api/configs/{dir_name}")
    if app_manager_src.exists():
        for dir_name in sorted([d.name for d in app_manager_src.iterdir() if d.is_dir()]):
            if dir_name == 'statics':
                print(f"  ./configs/sesame-app-manager/{dir_name:<21} → /data/apps/web/src/public/config")
            elif dir_name == 'config':
                print(f"  ./configs/sesame-app-manager/{dir_name:<21} → /data/apps/web/config")
            else:
                print(f"  ./configs/sesame-app-manager/{dir_name:<21} → /data/apps/web/config/{dir_name}")
    print()

    time.sleep(1)

    # Étape 8: Vérification finale
    log_info("Étape 8/8: Vérification finale de l'état du système...")
    
    # Vérifier que le dump existe
    dump_dir = Path("dump")
    if dump_dir.exists() and any(dump_dir.iterdir()):
        log_info("✓ Dump de la base de données présent dans ./dump/")
    else:
        log_warn("Aucun dump trouvé dans ./dump/")
    
    # Vérifier que la sauvegarde existe
    if Path("docker-compose.yml.v1.backup").exists():
        log_info("✓ Sauvegarde docker-compose.yml.v1.backup créée")
    
    log_info("Migration terminée avec succès!")
    print()
    print("=" * 50)
    print("Prochaines étapes:")
    print("=" * 50)
    print("1. Vérifiez le nouveau docker-compose.yml")
    print("2. Lancez les services avec: docker-compose up -d")
    print("3. Vérifiez les logs: docker-compose logs -f")
    print()
    print("En cas de problème, vous pouvez restaurer avec:")
    print("  cp docker-compose.yml.v1.backup docker-compose.yml")
    print("=" * 50)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print()
        log_warn("Upgrade interrompu par l'utilisateur")
        sys.exit(1)
    except Exception as e:
        log_error(f"Erreur inattendue: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
