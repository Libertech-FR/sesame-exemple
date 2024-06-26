.DEFAULT_GOAL := help
help:
	@printf "\033[33mUsage:\033[0m\n  make [target] [arg=\"val\"...]\n\n\033[33mTargets:\033[0m\n"
	@grep -E '^[-a-zA-Z0-9_\.\/]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-15s\033[0m %s\n", $$1, $$2}'

sesame-run: ## Run the Sesame server
	@docker compose up -d

sesame-stop: ## Stop the Sesame server
	@docker compose down

sesame-update: ## Update the Sesame server
	@docker compose pull
	@docker compose up -d

sesame-import-taiga: ## Import Taiga data
	@docker pull ghcr.io/libertech-fr/sesame-taiga_crawler:latest
	@docker run --rm -it \
		-v $(CURDIR)/configs/sesame-taiga-crawler/config.yml:/data/config.yml \
		-v $(CURDIR)/configs/sesame-taiga-crawler/data:/data/data \
                -v $(CURDIR)/configs/sesame-taiga-crawler/cache:/data/cache \
		-v $(CURDIR)/configs/sesame-taiga-crawler/.env:/data/.env \
		--network sesame \
		ghcr.io/libertech-fr/sesame-taiga_crawler:latest

sesame-import-taiga-taiga: ## Import only Taiga data without pushing them in Sesame
	@docker pull ghcr.io/libertech-fr/sesame-taiga_crawler:latest
	@docker run --rm -it \
		-v $(CURDIR)/configs/sesame-taiga-crawler/config.yml:/data/config.yml \
		-v $(CURDIR)/configs/sesame-taiga-crawler/data:/data/data \
                -v $(CURDIR)/configs/sesame-taiga-crawler/cache:/data/cache \
		-v $(CURDIR)/configs/sesame-taiga-crawler/.env:/data/.env \
		--network sesame \
		ghcr.io/libertech-fr/sesame-taiga_crawler:latest \
	        python /data/main.py taiga

sesame-import-taiga-sesame: ## pushing them in Sesame
	@docker pull ghcr.io/libertech-fr/sesame-taiga_crawler:latest
	@docker run --rm -it \
		-v $(CURDIR)/configs/sesame-taiga-crawler/config.yml:/data/config.yml \
		-v $(CURDIR)/configs/sesame-taiga-crawler/data:/data/data \
                -v $(CURDIR)/configs/sesame-taiga-crawler/cache:/data/cache \
		-v $(CURDIR)/configs/sesame-taiga-crawler/.env:/data/.env \
		--network sesame \
		ghcr.io/libertech-fr/sesame-taiga_crawler:latest \
	        python /data/main.py sesame

sesame-import: ## Import data
	@docker pull ghcr.io/libertech-fr/sesame-crawler:latest
	@docker run --rm -it \
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
	@docker exec -it sesame-orchestrator \
		yarn console backends syncall

sesame-dump: ## Dump database
	@[ -d $(CURDIR)/dump ] || mkdir -p $(CURDIR)/dump
	@chown 999 ${CURDIR}/dump
	@docker run --rm -it -v ./dump:/data/dump --user=0 --network sesame mongo:7.0 mongodump --host=sesame-mongo --out=/data/dump
