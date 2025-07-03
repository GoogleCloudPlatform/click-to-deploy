#!/bin/bash

function setup_postgres() {
  docker run \
  --tty \
  --net airflow \
  --name some-postgres \
  -e POSTGRES_USER=airflow \
  -e POSTGRES_PASSWORD=airflow \
  -e POSTGRES_DB=airflow \
  -e MYSQL_ROOT_PASSWORD=some-password \
  -d marketplace.gcr.io/google/postgresql13
}

function setup_airflow() {
  docker run \
  --tty \
  --net airflow \
  --name some-airflow \
  -e "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@some-postgres/airflow" \
  -e AIRFLOW_UID=50000 \
  -e _AIRFLOW_DB_UPGRADE=true \
  -e _AIRFLOW_WWW_USER_CREATE=true \
  -e _AIRFLOW_WWW_USER_USERNAME=airflow \
  -e _AIRFLOW_WWW_USER_PASSWORD=airflow \
  -d $image api-server
}

function setup_test_airflow() {
  docker run \
  --tty \
  --net airflow \
  --name some-airflow \
  -e "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@some-postgres/airflow" \
  -e AIRFLOW_UID=50000 \
  -e _AIRFLOW_DB_UPGRADE=true \
  -e _AIRFLOW_WWW_USER_CREATE=true \
  -e _AIRFLOW_WWW_USER_USERNAME=airflow \
  -e _AIRFLOW_WWW_USER_PASSWORD=airflow \
  -u 0:0 \
  --entrypoint sleep \
  -d $image 3600
}

declare -r command="$1"
declare -r image="$2"

if [[ "${command}" == "db" || "${command}" == "all" ]]; then
  echo >&2 "Launching PostgreSQL..."
  setup_postgres
  sleep 30s
  echo >&2 "PostgreSQL seems to be ready."
fi

if [[ "${command}" == "airflow" || "${command}" == "all" ]]; then
  echo >&2 "Launching Airflow..."
  setup_airflow
fi

if [[ "${command}" == "airflow_test" ]]; then
  echo >&2 "Launching testing Airflow..."
  setup_test_airflow
fi
