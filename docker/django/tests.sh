#!/bin/bash

function remove_containers() {
  docker rm -f $(docker ps -aq)
}

remove_containers

IMAGE="$1"

echo >&2 "Starting PostgreSQL..."
docker run \
  --net django \
  --name some-postgres \
  -e POSTGRES_USER=django \
  -e POSTGRES_PASSWORD=django \
  -e POSTGRES_DB=django \
  -d marketplace.gcr.io/google/postgresql13

echo >&2 "Starting Django container: ${IMAGE}..."
docker run -d \
  --net django \
  --name some-django \
  -p "127.0.0.1:8081:8080" \
  -p "127.0.0.1:1717:1717" \
  -e "C2D_DJANGO_SITENAME=mysite" \
  -e "C2D_DJANGO_ALLOWED_HOSTS='.localhost', '127.0.0.1', '[::1]'" \
  -e "C2D_DJANGO_PORT=8080" \
  -e "C2D_DJANGO_DB_TYPE=postgresql" \
  -e "C2D_DJANGO_DB_NAME=django" \
  -e "C2D_DJANGO_DB_USER=django" \
  -e "C2D_DJANGO_DB_PASSWORD=django" \
  -e "C2D_DJANGO_DB_HOST=some-postgres" \
  -e "C2D_DJANGO_DB_PORT=5432" \
  -e "C2D_DJANGO_MODE=http" -d "${IMAGE}"
