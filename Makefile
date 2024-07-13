default: help

CONTAINER_NAME := abcd-lab
IMAGE_NAME := abcd-lab
VOLUME_NAME := abcd-lab
EXPOSED_PORT := 8080
HOST_PORT := 8080
GREEN = \033[0;32m
WHITE = \033[0m

.PHONY: help
help: # Pokazuje pomoc
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

build-image:
	@echo "$(GREEN)[#ABCD]\t$(WHITE)Building image..."
	@docker build -t $(IMAGE_NAME) -f Dockerfile .

create-volume:
	@echo "$(GREEN)[#ABCD]\t$(WHITE)Creating volume..."
	@docker volume create $(VOLUME_NAME)

create-lab: build-image create-volume # Tworzy obraz Docker oraz wolumen
	@docker create --name $(CONTAINER_NAME) \
		-p $(HOST_PORT):$(EXPOSED_PORT) \
		-v $(VOLUME_NAME):/var/jenkins_home \
		-v /var/run/docker.sock:/var/run/docker.sock \
		$(IMAGE_NAME)
	@echo "$(GREEN)[#ABCD]\t$(WHITE) Start the lab enviroment by typing $(GREEN)make start-lab"

start-lab: # Uruchamia kontener Jenkins
	@if ! docker ps -a --filter "name=$(CONTAINER_NAME)" | grep -q $(CONTAINER_NAME); then \
		echo "$(GREEN)[#ABCD]\t$(WHITE)$(CONTAINER_NAME) container not found! Please run $(GREEN)make create-lab"; \
	else \
		echo "$(GREEN)[#ABCD]\t$(WHITE)Starting Docker container..."; \
		docker start $(CONTAINER_NAME); \
		sleep 5; \
		echo "$(GREEN)[#ABCD]\t$(WHITE)Container running at http://localhost:$(EXPOSED_PORT)"; \
		echo "$(GREEN)[#ABCD]\t$(WHITE)Jenkins username: admin; password: $$(docker exec -it $(CONTAINER_NAME) cat /var/jenkins_home/secrets/initialAdminPassword)"; \
	fi

stop-lab: # Stopuje kontener Jenkins
	@echo "$(GREEN)[#ABCD]\t$(WHITE)Shutting down Docker container..."
	@docker stop $(CONTAINER_NAME)

remove-container:
	@echo "$(GREEN)[#ABCD]\t$(WHITE)Removing $(CONTAINER_NAME) container..."
	@docker rm $(CONTAINER_NAME)

remove-volume:
	@echo "$(GREEN)[#ABCD]\t$(WHITE)Removing $(VOLUME_NAME) volume..."
	@docker volume rm $(VOLUME_NAME)

remove-image:
	@echo "$(GREEN)[#ABCD]\t$(WHITE)Removing $(IMAGE_NAME) image..."
	@docker image rmi $(IMAGE_NAME)

remove-lab: remove-container remove-volume remove-image # Usuwa kontener, wolumen oraz obaz
