# Si besoin à remplacer le nom de l'utilisateur docker final
DOCKER_USER=jeromeklam
DOCKER_REGISTRY=jeromeklam

# Map de port, si le 80 est déjà pris
PORT:=127.0.0.1:8883

# Nom du container
NAME:=apache2-php7

# Chemin courant = real_path
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Id, ... de docker
RUNNING:=$(shell docker ps | grep $(NAME) | cut -f 1 -d ' ')
ALL:=$(shell docker ps -a | grep $(NAME) | cut -f 1 -d ' ')

# Options de la ligne de commande
DOCKER_RUN_COMMON=--name="$(NAME)" -p $(PORT):80 -v $(ROOT_DIR):/var/www/html -v $(ROOT_DIR)/docker-logs:/var/log/apache2 $(DOCKER_USER)/$(NAME)

# Par défaut le build
all: build

# Compilation de l'image
build: clean
	mkdir -p $(ROOT_DIR)/docker-logs
	mkdir -p $(ROOT_DIR)/www
	docker build -t="$(DOCKER_USER)/$(NAME)" .

# Démarrage du container
run: clean
	mkdir -p $(ROOT_DIR)/docker-logs
	mkdir -p $(ROOT_DIR)/www
	docker run -d $(DOCKER_RUN_COMMON)

# Arrêt du container
stop: clean

# Démarrage d'un bash sur le container
bash: clean
	mkdir -p $(ROOT_DIR)/docker-logs
	mkdir -p $(ROOT_DIR)/www
	docker run -t -i $(DOCKER_RUN_COMMON) /bin/bash

# Push to registry
push: build
	docker tag $(shell docker images -q $(DOCKER_USER)/$(NAME)) $(DOCKER_REGISTRY)/$(NAME)
	docker push $(DOCKER_REGISTRY)/$(NAME)
	docker rmi --force $(shell docker images -q $(DOCKER_USER)/$(NAME))

# Supprime les containers existants
clean:
ifneq ($(strip $(RUNNING)),)
	docker stop $(RUNNING)
endif
ifneq ($(strip $(ALL)),)
	docker rm $(ALL)
endif

# Nettoyage complet !!!
deepclean: clean
	rm -rf $(ROOT_DIR)/docker-logs
