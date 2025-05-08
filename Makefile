# Makefile para gestionar despliegues con Docker Compose

# Archivos base
COMPOSE_FILE=docker-compose.yml
MYSQL_OVERRIDE=etc/docker/compose/docker-compose.override.mysql.yml
MONGO_OVERRIDE=etc/docker/compose/docker-compose.override.mongo.yml
# Default profile, this makefile is thinked to work locally
PROFILE=dev

.PHONY: menu

menu:
	@echo "\n======= PHP Dev Environment ======="
	@echo "Elige una opción para desplegar tu entorno:"
	@echo ""
	@echo "1) Levantar solo el entorno web (default)"
	@echo "2) Levantar entorno con MySQL + phpMyAdmin"
	@echo "3) Levantar entorno con MongoDB + Mongo Express"
	@echo "4) Apagar y limpiar contenedores"
	@echo "5) Limpiar todo (contenedores, volúmenes, imágenes)"
	@echo ""
	@read -p "Selecciona una opción [1-5]: " option; \
	 case $$option in \
		1) docker compose -f $(COMPOSE_FILE) up -d ;; \
		2) docker compose -f $(COMPOSE_FILE) -f $(MYSQL_OVERRIDE) --profile $(PROFILE) up -d ;; \
		3) docker compose -f $(COMPOSE_FILE) -f $(MONGO_OVERRIDE) --profile $(PROFILE) up -d ;; \
		4) docker compose down -v --remove-orphans ;; \
		5) docker system prune -a --volumes --force ;; \
		*) echo "Opción inválida." ;; \
	 esac
