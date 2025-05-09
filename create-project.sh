#!/bin/bash

# Load conf from .env if exists
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Check the APACHE_PORT_RANGE for range ports
if [ -z "$APACHE_PORT_RANGE" ]; then
  echo "❌ The variable APACHE_PORT_RANGE isn't defined in .env"
  exit 1
fi

# Extract ports
PORT_START=$(echo "$APACHE_PORT_RANGE" | cut -d'-' -f1)
PORT_END=$(echo "$APACHE_PORT_RANGE" | cut -d'-' -f2)

# Structure project to copy the files
HTDOCS_PATH="./htdocs"
VHOSTS_PATH="./etc/docker/apache2/sites-available"
DOMAIN_SUFFIX=".test"

# Find the fre port on range
find_free_port() {
  USED_PORTS=$(grep -rhoE 'VirtualHost \*:[0-9]+' "$VHOSTS_PATH"/*.conf 2>/dev/null | cut -d: -f2 | sort -n | uniq)
  for port in $(seq "$PORT_START" "$PORT_END"); do
    # Skip first port (reserved for dashboard)
    if [ "$port" -eq "$PORT_START" ]; then
      continue
    fi
    if ! echo "$USED_PORTS" | grep -q "^$port$"; then
      echo "$port"
      return
    fi
  done
  echo "❌ There aren't free ports on range $APACHE_PORT_RANGE" >&2
  exit 1
}

# Check if the script is run with a project name argument
if [ -z "$1" ]; then
  echo "Uso: $0 project_name"
  exit 1
fi

PROJECT_NAME=$1
PROJECT_PATH="${HTDOCS_PATH}/${PROJECT_NAME}"
VHOST_FILE="${VHOSTS_PATH}/${PROJECT_NAME}.conf"

# Check if the project already exists
if [ -d "$PROJECT_PATH" ]; then
  echo "❌ Project '$PROJECT_NAME' already exists at $PROJECT_PATH"
  exit 1
fi

# Check if the VirtualHost already exists
if [ -f "$VHOST_FILE" ]; then
  echo "❌ VirtualHost config for '$PROJECT_NAME' already exists at $VHOST_FILE"
  exit 1
fi

# Check if port is available
PORT=$(find_free_port)

if [ -z "$PORT" ]; then
  echo "❌ No available ports found in range $APACHE_PORT_RANGE"
  exit 1
fi

# Create a new project structure
mkdir -p "${PROJECT_PATH}/public"
echo "<?php phpinfo(); ?>" > "${PROJECT_PATH}/public/index.php"

# Create a VirtualHost from template
TEMPLATE_PATH="./etc/templates/apache2/sites-available/vhost.conf.template"

if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "❌ Template file not found at $TEMPLATE_PATH"
  exit 1
fi

# Export required vars for envsubst
export PORT PROJECT_NAME DOMAIN_SUFFIX

echo "PORT=$PORT"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "DOMAIN_SUFFIX=$DOMAIN_SUFFIX"

# Create a VirtualHost from the template
mkdir -p "$VHOSTS_PATH"
# envsubst will be replace only the defined or exported variables (doesn't replace that are not defined)
envsubst '${PORT} ${PROJECT_NAME} ${DOMAIN_SUFFIX}' < "$TEMPLATE_PATH" > "$VHOST_FILE"

echo "✅ Created project in ${PROJECT_PATH}"
echo "📝 VirtualHost generated in ${VHOST_FILE}"
echo "🔄 You have to reload Apache(docker-compose down && up) to review the changes."