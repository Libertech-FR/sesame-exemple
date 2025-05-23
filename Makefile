#!/usr/bin/make -f
# Version: 2024-07-25_12-14

TMP_DIR := /tmp
MAKEFILE_SELF_BRANCH := main
MAKEFILE_SELF_REPO := https://raw.githubusercontent.com/Libertech-FR/sesame-exemple/$(MAKEFILE_SELF_BRANCH)/Makefile
DAEMON_PLATFORM := amd64
DAEMON_PKG_NAME := sesame-daemon_%s_$(DAEMON_PLATFORM).deb
DAEMON_REPO := libertech-fr/sesame-daemon
DAEMON_GITHUB_API := https://api.github.com/repos/$(DAEMON_REPO)/tags
DAEMON_DOWNLOAD_URL := https://github.com/$(DAEMON_REPO)/releases/download/%s/%s

.DEFAULT_GOAL := help
help:
	@printf "\033[33mUsage:\033[0m\n  make [target] [arg=\"val\"...]\n\n\033[33mTargets:\033[0m\n"
	@grep -E '^[-a-zA-Z0-9_\.\/]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-15s\033[0m %s\n", $$1, $$2}'

sesame-run: ## Run the Sesame server
	@docker compose up -d

sesame-stop: ## Stop the Sesame server
	@docker compose down

sesame-self-update: ## Self update Sesame Makefile
	@echo "Mise à jour du fichier Makefile..."
	@if [ -f Makefile ]; then \
		MOD_DATE=$$(date -r Makefile "+%Y-%m-%d_%H-%M-%S"); \
		echo "Un Makefile est présent. Création d'un point de restauration (.Makefile.$${MOD_DATE})"; \
		mv Makefile .Makefile.$${MOD_DATE}; \
	fi
	@curl -s -H "Cache-Control: no-cache" -o Makefile $(MAKEFILE_SELF_REPO)
	@if [ $$? -ne 0 ]; then \
		echo "Le téléchargement du nouveau Makefile a échoué. Restauration de l'ancien Makefile..."; \
		mv Makefile.$${MOD_DATE} Makefile; \
	else \
		echo "Mise à jour terminée."; \
	fi

sesame-update: ## Update the Sesame server
	@docker pull ghcr.io/libertech-fr/sesame-taiga_crawler:latest
	@docker compose pull
	@docker compose up -d

sesame-update-daemon: ## Update the Sesame Daemon (pkg)
	@echo "Téléchargement du package pour le tag le plus récent"
	@LATEST_TAG=$$(curl -s $(DAEMON_GITHUB_API) | jq -r '.[0].name' | sed 's/^v//'); \
		FINAL_DAEMON_PKG_NAME=$$(printf "$(DAEMON_PKG_NAME)" $$LATEST_TAG); \
		DOWNLOAD_URL=$$(printf "$(DAEMON_DOWNLOAD_URL)" $$LATEST_TAG $$FINAL_DAEMON_PKG_NAME); \
		echo "Téléchargement du package <$$FINAL_DAEMON_PKG_NAME> depuis <$$DOWNLOAD_URL>"; \
		curl -s -H "Cache-Control: no-cache" -L -o $(TMP_DIR)/$$FINAL_DAEMON_PKG_NAME $$DOWNLOAD_URL; \
		dpkg -i $(TMP_DIR)/$$FINAL_DAEMON_PKG_NAME

sesame-daemon-get-latest: ## Update the Sesame Daemon (pkg)
	@echo "Récupération du tag le plus récent du dépôt $(DAEMON_REPO) via l'API GitHub"
	@LATEST_TAG=$$(curl -s $(DAEMON_GITHUB_API) | jq -r '.[0].name' | sed 's/^v//'); \
		echo "Le tag le plus récent est: $$LATEST_TAG"

sesame-import-taiga: ## Import Taiga data
	@$(eval an ?= '0')
	@$(eval imports ?= 'all')
	@$(eval force ?= '0')
	@docker run --rm  \
		-v $(CURDIR)/configs/sesame-taiga-crawler/config.yml:/data/config.yml \
		-v $(CURDIR)/configs/sesame-taiga-crawler/data:/data/data \
                -v $(CURDIR)/configs/sesame-taiga-crawler/cache:/data/cache \
		-v $(CURDIR)/configs/sesame-taiga-crawler/.env:/data/.env \
		--network sesame \
		ghcr.io/libertech-fr/sesame-taiga_crawler:latest python /data/main.py --an=$(an) --imports=$(imports) --force=$(force)

sesame-import-taiga-taiga: ## Import only Taiga data without pushing them in Sesame
	@$(eval imports ?= 'all')
	@$(eval force ?= '0')
	@docker run --rm  \
		-v $(CURDIR)/configs/sesame-taiga-crawler/config.yml:/data/config.yml \
		-v $(CURDIR)/configs/sesame-taiga-crawler/data:/data/data \
                -v $(CURDIR)/configs/sesame-taiga-crawler/cache:/data/cache \
		-v $(CURDIR)/configs/sesame-taiga-crawler/.env:/data/.env \
		--network sesame \
		ghcr.io/libertech-fr/sesame-taiga_crawler:latest \
	        python /data/main.py --run=taiga --imports=$(imports) --force=$(force)

sesame-import-taiga-sesame: ## pushing them in Sesame
	@$(eval imports ?= 'all')
	@$(eval force ?= '0')
	@docker run --rm  \
		-v $(CURDIR)/configs/sesame-taiga-crawler/config.yml:/data/config.yml \
		-v $(CURDIR)/configs/sesame-taiga-crawler/data:/data/data \
                -v $(CURDIR)/configs/sesame-taiga-crawler/cache:/data/cache \
		-v $(CURDIR)/configs/sesame-taiga-crawler/.env:/data/.env \
		--network sesame \
		ghcr.io/libertech-fr/sesame-taiga_crawler:latest \
	        python /data/main.py --run=sesame --imports=$(imports) --force=$(force)

sesame-import: ## Import data
	@docker run --rm  \
		-v $(CURDIR)/import/config.yml:/data/config.yml \
		-v $(CURDIR)/import/data:/data/data \
		-v $(CURDIR)/import/cache:/data/cache \
		-v $(CURDIR)/import/.env:/data/.env \
		--network sesame \
		ghcr.io/libertech-fr/sesame-crawler:latest

sesame-generate-jwt-secret: ## Generate a JWT token
	@docker run --rm mihaigalos/randompass --length 32

sesame-create-agent: ## Create new agent in Sesame ochestrator
	@docker exec -it sesame-orchestrator \
		yarn console agents create

sesame-create-keyring: ## Create new keyring token for Sesame ochestrator API
	@docker exec -it sesame-orchestrator \
		yarn console keyrings create

sesame-backends-syncall: ## Sync all identities from TO_SYNC status
	@docker exec  sesame-orchestrator \
		yarn console backends syncall

sesame-dump: ## Dump database
	@[ -d $(CURDIR)/dump ] || mkdir -p $(CURDIR)/dump
	@chown 999 ${CURDIR}/dump
	@docker run --rm  -v ./dump:/data/dump --user=0 --network sesame mongo:7.0 mongodump --host=sesame-mongo --out=/data/dump
