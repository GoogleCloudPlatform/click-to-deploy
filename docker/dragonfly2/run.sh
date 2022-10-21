#!/bin/bash

declare -r NAME="${RANDOM}"
declare -r IMAGE="dragonfly-manager"
declare -r NETWORK="testunique-$RANDOM"

docker network create -d bridge "${NETWORK}"
docker run --net "${NETWORK}" --name some-redis-$NAME-id -d -p '6379:6379' 'marketplace.gcr.io/google/redis6' --requirepass dragonfly
docker run --net "${NETWORK}" --name some-mysql-$NAME-id -d -p '3306:3306' -e 'MARIADB_USER=dragonfly' -e 'MARIADB_PASSWORD=dragonfly' -e 'MARIADB_DATABASE=manager' -e 'MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes' marketplace.gcr.io/google/mariadb10

sleep 5s

docker run \
  --net "${NETWORK}" \
  --name some-dragonfly-manager-$NAME-id -d \
  -p '127.0.0.1:8080:8080' -p '65003:65003' \
  -e "DRAGONFLY_MYSQL_HOST=some-mysql-$NAME-id" \
  -e "DRAGONFLY_REDIS_HOST=some-redis-$NAME-id" $IMAGE

sleep 3660s
