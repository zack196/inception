DATA_DIR=$(HOME)/"data"
DATA_WEBSITE=$(DATA_DIR)/"data-website"
DATA_DATABASE=$(DATA_DIR)/"data-base"
DOCKER_COMPOSE="srcs/docker-compose.yml"

all: setup up

up:
	docker-compose -f $(DOCKER_COMPOSE) up -d

setup:
	@sudo mkdir -p $(DATA_DIR) $(DATA_DATABASE) $(DATA_WEBSITE)
	@sudo chmod 777 $(DATA_DIR) $(DATA_DATABASE) $(DATA_WEBSITE)

clean:
	docker-compose -f $(DOCKER_COMPOSE) down

fclean: clean
	@sudo rm -rf $(DATA_DATABASE) $(DATA_WEBSITE) $(DATA_DIR)
	@docker rmi -f $$(docker images -q) || true

re: fclean all