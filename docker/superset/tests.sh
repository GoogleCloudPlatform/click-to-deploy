#!/bin/bash

# IMAGE="superset3:3.0"
IMAGE="superset2:2.1"

# docker network create -d bridge superset-net

docker run \
  --net superset-net \
  --name some-postgres \
  -e POSTGRES_USER=superset \
  -e POSTGRES_PASSWORD=superset \
  -e POSTGRES_DB=superset \
  -e MYSQL_ROOT_PASSWORD=some-password \
  -d marketplace.gcr.io/google/postgresql13

sleep 20s

docker run \
  --net superset-net \
  --name some-superset \
  -e SUPERSET__SQLALCHEMY_DATABASE_URI=postgresql+psycopg2://superset:superset@some-postgres-$UNIQUE-id/superset \
  -e SUPERSET_SECRET_KEY=Lb3qA1jr7AZ945ccVUptd+ja8ZEJdmKahFJA240obgu4NzIuy4CJPOYP \
  -e DATABASE_HOST=db \
  -e DATABASE_DB=superset \
  -e DATABASE_USER=superset \
  -e DATABASE_PASSWORD=superset \
  -p 127.0.0.1:8088:8088 \
  -d $IMAGE

sleep 90s
