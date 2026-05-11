SHELL := /bin/bash
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PROJECT_ROOT := $(ROOT_DIR)/..
COMPOSE_FILE := $(PROJECT_ROOT)/infra/docker/docker-compose.yml
ENV_FILE := $(PROJECT_ROOT)/.env
COMPOSE := docker compose -p base-msa-template --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

.PHONY: build test clean run rebuild rebuild-nc run-local run-infra stop logs ps create-service help

help:
	@echo "Available targets:"
	@echo "  build          - Build all modules (skip tests)"
	@echo "  test           - Run all tests"
	@echo "  clean          - Clean all build outputs"
	@echo "  run            - Start full stack (all services + infra)"
	@echo "  rebuild        - Rebuild images and start full stack"
	@echo "  rebuild-nc     - Rebuild images (no cache) and start full stack"
	@echo "  run-local      - Start infra only (postgres + redis)"
	@echo "  stop           - Stop all containers"
	@echo "  logs           - Tail logs (SERVICE=<name> for specific service)"
	@echo "  ps             - Show container status"
	@echo "  create-service - Scaffold a new service (NAME=<service-name>)"

build:
	@cd $(PROJECT_ROOT) && ./gradlew build -x test

test:
	@cd $(PROJECT_ROOT) && ./gradlew test

clean:
	@cd $(PROJECT_ROOT) && ./gradlew clean

run:
	@$(COMPOSE) up -d

rebuild:
	@$(COMPOSE) up --build -d

rebuild-nc:
	@$(COMPOSE) build --no-cache
	@$(COMPOSE) up -d

run-local:
	@$(COMPOSE) up postgres redis -d

stop:
	@$(COMPOSE) down

logs:
ifdef SERVICE
	@$(COMPOSE) logs -f $(SERVICE)
else
	@$(COMPOSE) logs -f
endif

ps:
	@$(COMPOSE) ps

create-service:
ifndef NAME
	$(error NAME is required. Usage: make create-service NAME=<service-name>)
endif
	@$(ROOT_DIR)/create-service.sh $(NAME)
