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
        @docker run --rm -it \
          -v $(CURDIR)/configs:/app/configs \
          --network sesame \
          ghcr.io/libertech-fr/sesame-taiga_crawler:latest

sesame-generate-jwt-secret: ## Generate a JWT token
	@docker run --rm mihaigalos/randompass --length 32
