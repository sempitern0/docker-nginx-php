.DEFAULT_GOAL := help

BASE_DOMAIN ?= app.test

CERT_DOMAINS ?= $(BASE_DOMAIN) *.$(BASE_DOMAIN)
CERT_DIR ?= nginx/certs
CERT_NAME ?= app

CERT_SCRIPT_WINDOWS ?= scripts/generate_certs.ps1
CERT_SCRIPT_UNIX ?= scripts/generate_certs.sh

COMPOSE ?= docker compose

PHP_SERVICE ?= php
NGINX_SERVICE ?= webserver


GREEN  := \033[0;32m
YELLOW := \033[0;33m
BLUE   := \033[0;34m
CYAN   := \033[0;36m
RED    := \033[0;31m
RESET  := \033[0m


.PHONY: help \
	setup \
	chmod \
	init-dirs \
	certs \
	up \
	up-detached \
	up-build \
	down \
	stop \
	start \
	restart \
	restart-rebuild \
	ps \
	top \
	build \
	build-nc \
	pull \
	rebuild \
	logs \
	logs-nginx \
	logs-php \
	logs-tail \
	shell \
	php \
	nginx \
	config \
	images \
	stats \
	php-version \
	php-extensions \
	clean \
	clean-images \
	destroy-volumes \
	destroy \
	reset \
	fresh \
	certs-force \
	certs-check


help: ## Show available commands
	@echo ""
	@echo "$(CYAN)Docker-Nginx-PHP$(RESET)"
	@echo "Base domain: $(BASE_DOMAIN)"
	@echo ""
	@echo "$(YELLOW)Setup$(RESET)"
	@grep -E '^[a-zA-Z0-9_-]+:.*## ' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""


setup: chmod init-dirs certs up-build ## Full setup: permissions, directories, SSL certificates and Docker build
	@echo ""
	@echo "================================================================="
	@echo " Docker-Nginx-PHP is ready!"
	@echo ""
	@echo " Remember to add these lines to your hosts file:"
	@echo "   127.0.0.1 $(BASE_DOMAIN)"
	@echo "   ::1       $(BASE_DOMAIN)"
	@echo ""
	@echo " Application available at:"
	@echo "   https://$(BASE_DOMAIN)"
	@echo "================================================================="
	@echo ""


chmod: ## Make certificate script executable on Unix systems
	@if [ -f "$(CERT_SCRIPT_UNIX)" ]; then \
		chmod +x "$(CERT_SCRIPT_UNIX)"; \
	fi

init-dirs: ## Create required project directories
	@mkdir -p "$(CERT_DIR)"
	@echo "$(GREEN)✓ Required directories ready$(RESET)"


certs: ## Generate local SSL certificates using mkcert
	@echo ""
	@echo "$(CYAN)Generating local SSL certificate...$(RESET)"
	@echo "  Domain : $(BASE_DOMAIN)"
	@echo "  SANs   : $(CERT_DOMAINS)"
	@echo ""

ifeq ($(OS),Windows_NT)

	@powershell -NoProfile -ExecutionPolicy Bypass -File "$(CERT_SCRIPT_WINDOWS)" \
		-OutputDir "$(CERT_DIR)" \
		-FileName "$(CERT_NAME)" \
		-Domains "$(CERT_DOMAINS)" \
		-Tool mkcert

else

	@./"$(CERT_SCRIPT_UNIX)" \
		--output "$(CERT_DIR)" \
		--name "$(CERT_NAME)" \
		--domains "$(CERT_DOMAINS)" \
		--tool mkcert

endif

	@echo ""
	@echo "$(GREEN)✓ SSL certificates ready$(RESET)"
	@echo ""


certs-force: ## Regenerate SSL certificates
	@echo "$(YELLOW)Regenerating SSL certificates...$(RESET)"
	@$(MAKE) certs


certs-check: ## Check generated SSL certificate files
	@if [ -f "$(CERT_DIR)/$(CERT_NAME).crt" ] && [ -f "$(CERT_DIR)/$(CERT_NAME).key" ]; then \
		echo "$(GREEN)✓ SSL certificate files found$(RESET)"; \
		echo "  Certificate: $(CERT_DIR)/$(CERT_NAME).crt"; \
		echo "  Private key: $(CERT_DIR)/$(CERT_NAME).key"; \
	else \
		echo "$(RED)✗ SSL certificate files not found$(RESET)"; \
		echo "  Run: make certs"; \
		exit 1; \
	fi


up: ## Start containers in foreground
	$(COMPOSE) up

up-detached: ## Start containers in background
	$(COMPOSE) up -d

up-build: ## Rebuild and start containers in background
	$(COMPOSE) up -d --build

down: ## Stop and remove containers
	$(COMPOSE) down --remove-orphans

stop: ## Stop containers without removing them
	$(COMPOSE) stop

start: ## Start existing stopped containers
	$(COMPOSE) start

restart: ## Restart all containers
	$(COMPOSE) restart

restart-rebuild: ## Rebuild images and restart all containers
	$(COMPOSE) up -d --build --force-recreate

ps: ## Show container status
	$(COMPOSE) ps

top: ## Show running processes inside containers
	$(COMPOSE) top



build: ## Build container images
	$(COMPOSE) build

build-nc: ## Build container images without cache
	$(COMPOSE) build --no-cache

pull: ## Pull latest base images
	$(COMPOSE) pull

rebuild: down build up-detached ## Stop, rebuild and start containers


logs: ## Follow logs from all services
	$(COMPOSE) logs -f

logs-nginx: ## Follow Nginx logs
	$(COMPOSE) logs -f $(NGINX_SERVICE)

logs-php: ## Follow PHP logs
	$(COMPOSE) logs -f $(PHP_SERVICE)

logs-tail: ## Show last 100 log lines
	$(COMPOSE) logs --tail=100

shell: ## Open a shell in the PHP container
	$(COMPOSE) exec $(PHP_SERVICE) sh

php: ## Open a shell in the PHP container
	$(COMPOSE) exec $(PHP_SERVICE) sh

nginx: ## Open a shell in the Nginx container
	$(COMPOSE) exec $(NGINX_SERVICE) sh


config: ## Validate and display Docker Compose configuration
	$(COMPOSE) config

images: ## List Docker images used by the project
	$(COMPOSE) images

stats: ## Show live container resource usage
	docker stats

php-version: ## Show PHP version
	$(COMPOSE) exec $(PHP_SERVICE) php -v

php-extensions: ## Show installed PHP extensions
	$(COMPOSE) exec $(PHP_SERVICE) php -m


clean: ## Remove stopped containers and unused networks
	$(COMPOSE) down --remove-orphans

clean-images: ## Remove project Docker images
	$(COMPOSE) down --rmi local --remove-orphans

destroy-volumes: ## Tear down containers and volumes
	$(COMPOSE) down --volumes --remove-orphans

destroy: ## Tear down containers, networks, images and volumes
	$(COMPOSE) down --rmi all --volumes --remove-orphans


reset: destroy certs up-build ## Completely reset Docker environment and rebuild it
fresh: destroy init-dirs certs up-build ## Fresh Docker environment from scratch