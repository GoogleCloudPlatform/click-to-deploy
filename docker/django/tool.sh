#!/bin/bash

declare -r command="$1"

function build() {
  docker build -t django4:4.1 4/debian11/4.1
  docker build -t uwsgi-exporter1:1.1 exporter/
}

function run() {
  docker run -d \
    -e "C2D_DJANGO_SITENAME=mysite" \
    -e "C2D_DJANGO_PORT=8080" \
    django:4.1
}

function debug() {
  docker run -d \
    --entrypoint sleep \
    django4:4.1 \
    3600
}

function delete_all() {
  docker rm -f `docker ps -aq`
}

function generate_files() {
  /google/data/ro/teams/cloud-marketplace-ops/dockerfiles -create_directories
}

function push() {
  docker tag django4:4.1 gcr.io/ccm-ops-test-adhoc/django4:4.1
  docker push gcr.io/ccm-ops-test-adhoc/django4:4.1
  docker tag uwsgi-exporter1:1.1 gcr.io/ccm-ops-test-adhoc/uwsgi-exporter1:1.1
  docker push gcr.io/ccm-ops-test-adhoc/uwsgi-exporter1:1.1
}

function run_with_mysql() {
  # Remove sites volume
  local -r count_vols="$(docker volume ls | grep sites | wc -l)"
  if [[ "${count_vols}" -gt 0 ]]; then
    docker volume rm sites
  fi

  # Run MySQL
  docker run \
    --name django-mysql \
    --network django \
    -e "MYSQL_ROOT_PASSWORD=example-password" \
    -e "MYSQL_USER=websiteuser" \
    -e "MYSQL_PASSWORD=websitepwd" \
    -e "MYSQL_DATABASE=websitedb" \
    -p 127.0.0.1:3306:3306 \
    -d \
    marketplace.gcr.io/google/mysql5

  echo "Awaiting a little bit..."
  # sleep 10

  # Run Django 1
  docker run -d \
    --name django-web-1 \
    --network django \
    -e "C2D_DJANGO_SITENAME=mysite" \
    -e "C2D_DJANGO_PORT=8080" \
    -e "C2D_DJANGO_DB_TYPE=mysql" \
    -e "C2D_DJANGO_DB_NAME=websitedb" \
    -e "C2D_DJANGO_DB_USER=websiteuser" \
    -e "C2D_DJANGO_DB_PASSWORD=websitepwd" \
    -e "C2D_DJANGO_DB_HOST=django-mysql" \
    -e "C2D_DJANGO_DB_PORT=3306" \
    -p 127.0.0.1:8080:8080 \
    -p 127.0.0.1:1717:1717 \
    -v "sites:/sites/" \
    django4:4.1

  # Run Django 2
  docker run -d \
    --name django-web-2 \
    --network django \
    -e "C2D_DJANGO_SITENAME=mysite" \
    -e "C2D_DJANGO_PORT=8080" \
    -e "C2D_DJANGO_DB_TYPE=mysql" \
    -e "C2D_DJANGO_DB_NAME=websitedb" \
    -e "C2D_DJANGO_DB_USER=websiteuser" \
    -e "C2D_DJANGO_DB_PASSWORD=websitepwd" \
    -e "C2D_DJANGO_DB_HOST=django-mysql" \
    -e "C2D_DJANGO_DB_PORT=3306" \
    -p 127.0.0.1:8081:8080 \
    -p 127.0.0.1:1718:1717 \
    -v "sites:/sites/" \
    django4:4.1

  # Run UWSGI Exporter
  docker run -d \
    --name uwsgi-exporter \
    --network django \
    -p 127.0.0.1:9117:9117 \
    uwsgi-exporter1:1.1 --stats.uri tcp://django-web-1:1717
}

function run_with_pgsql() {
  # Run PostgreSQL
  docker run \
    --name django-pgsql \
    --network django \
    -e "POSTGRES_USER=websiteuser" \
    -e "POSTGRES_PASSWORD=websitepwd" \
    -e "POSTGRES_DB=websitedb" \
    -p 127.0.0.1:3306:3306 \
    -d \
    marketplace.gcr.io/google/postgresql13

  echo "Awaiting a little bit..."
  # sleep 10

  # Run Django
  docker run -d \
    --network django \
    -e "C2D_DJANGO_SITENAME=mysite" \
    -e "C2D_DJANGO_PORT=8080" \
    -e "C2D_DJANGO_DB_TYPE=postgresql" \
    -e "C2D_DJANGO_DB_NAME=websitedb" \
    -e "C2D_DJANGO_DB_USER=websiteuser" \
    -e "C2D_DJANGO_DB_PASSWORD=websitepwd" \
    -e "C2D_DJANGO_DB_HOST=django-pgsql" \
    -e "C2D_DJANGO_DB_PORT=5432" \
    -p 127.0.0.1:8080:8080 \
    django4:4.1
}

if [[ "${command}" == "build" ]]; then
  build
elif [[ "${command}" == "gen" ]]; then
  generate_files
elif [[ "${command}" == "run" ]]; then
  run
elif [[ "${command}" == "purge" ]]; then
  delete_all
elif [[ "${command}" == "debug" ]]; then
  debug
elif [[ "${command}" == "run-mysql" ]]; then
  run_with_mysql
elif [[ "${command}" == "run-pgsql" ]]; then
  run_with_pgsql
elif [[ "${command}" == "push" ]]; then
  push
elif [[ "${command}" == "all" ]]; then
  delete_all
  generate_files
  build
  run
fi
