#!/bin/bash

UNIQUE="$RANDOM"

# docker network create kafka
docker run -d --network kafka --hostname zk-$UNIQUE-id -e ZOO_4LW_COMMANDS_WHITELIST="*" --name zk-$UNIQUE-id --restart always "marketplace.gcr.io/google/zookeeper3"
docker run -d --network kafka --hostname kafka-$UNIQUE-id-1 -e "KAFKA_ZOOKEEPER_CONNECT=zk-$UNIQUE-id:2181" -e "KAFKA_ADVERTISED_HOST_NAME=kafka-$UNIQUE-id-1" -e "KAFKA_ADVERTISED_PORT=9092" -e "KAFKA_PORT=9092" --name kafka-$UNIQUE-id-1 kafka3:3.8
docker run -d --network kafka --hostname kafka-$UNIQUE-id-2 -e "KAFKA_ZOOKEEPER_CONNECT=zk-$UNIQUE-id:2181" -e "KAFKA_ADVERTISED_HOST_NAME=kafka-$UNIQUE-id-2" -e "KAFKA_ADVERTISED_PORT=9092" -e "KAFKA_PORT=9092" --name kafka-$UNIQUE-id-2 kafka3:3.8
sleep 5s
