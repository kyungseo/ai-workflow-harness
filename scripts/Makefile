SHELL := /bin/bash
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PROJECT_ROOT := $(ROOT_DIR)/..
COMPOSE_FILE := $(PROJECT_ROOT)/infra/docker/docker-compose.yml

.PHONY: build test clean run run-local run-infra stop logs ps create-service help

help:
	@echo "Available targets:"
	@echo "  build          - Build all modules (skip tests)"
	@echo "  test           - Run all tests"
	@echo "  clean          - Clean all build outputs"
	@echo "  run            - Start full stack (all services + infra)"
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
	@docker compose -f $(COMPOSE_FILE) up -d

run-local:
	@docker compose -f $(COMPOSE_FILE) up postgres redis -d

stop:
	@docker compose -f $(COMPOSE_FILE) down

logs:
ifdef SERVICE
	@docker compose -f $(COMPOSE_FILE) logs -f $(SERVICE)
else
	@docker compose -f $(COMPOSE_FILE) logs -f
endif

ps:
	@docker compose -f $(COMPOSE_FILE) ps

create-service:
ifndef NAME
	$(error NAME is required. Usage: make create-service NAME=<service-name>)
endif
	@$(ROOT_DIR)/create-service.sh $(NAME)
