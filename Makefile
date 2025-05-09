# Default compose files
COMPOSE_FILE=docker-compose.yml
MYSQL_OVERRIDE=etc/docker/compose/docker-compose.override.mysql.yml
MONGO_OVERRIDE=etc/docker/compose/docker-compose.override.mongo.yml
# Default profile, this makefile is thinked to work locally
PROFILE=dev

.PHONY: menu

menu:
	@echo "\n======= PHP Docker Portable Environment ======="
	@echo "Choose an option to deploy your environment:"
	@echo ""
	@echo "1) Launch only web environment"
	@echo "2) Launch environment with MySQL + phpMyAdmin"
	@echo "3) Launch environment with con MongoDB + Mongo Express"
	@echo "4) Down y clean containers"
	@echo "5) Clean all (containers, volumes, images)"
	@echo ""
	@read -p "Select an option [1-5]: " option; \
	 case $$option in \
		1) docker compose -f $(COMPOSE_FILE) up -d ;; \
		2) docker compose -f $(COMPOSE_FILE) -f $(MYSQL_OVERRIDE) --profile $(PROFILE) up -d ;; \
		3) docker compose -f $(COMPOSE_FILE) -f $(MONGO_OVERRIDE) --profile $(PROFILE) up -d ;; \
		4) docker compose down -v --remove-orphans ;; \
		5) docker system prune -a --volumes --force ;; \
		*) echo "Not valid option." ;; \
	 esac
