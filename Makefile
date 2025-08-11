SHELL := /bin/sh


DATA_DIR       := $(HOME)/data
WORDPRESS_DIR  := $(DATA_DIR)/wordpress
DATABASE_DIR   := $(DATA_DIR)/database


COMPOSE_FILE   := srcs/docker-compose.yml
PROJECT        := inception
DC             := docker-compose -p $(PROJECT) -f $(COMPOSE_FILE)


all: setup up

setup:
	@sudo mkdir -p "$(WORDPRESS_DIR)" "$(DATABASE_DIR)"
	@sudo chmod 755 "$(WORDPRESS_DIR)" "$(DATABASE_DIR)"
	# If DB perms act up later, try:
	@sudo chown -R 999:999 "$(DATABASE_DIR)"

up:
	@$(DC) up -d

down:
	@$(DC) down

restart:
	@$(DC) restart

build:
	@$(DC) build --pull

logs:
	@$(DC) logs -f

ps:
	@$(DC) ps

clean:
	@$(DC) down -v --rmi local --remove-orphans || true

fclean: clean
	@sudo rm -rf "$(WORDPRESS_DIR)" "$(DATABASE_DIR)"

re: fclean all

.PHONY: all setup up down restart build logs ps clean fclean re