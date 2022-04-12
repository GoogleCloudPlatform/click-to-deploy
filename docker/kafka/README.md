# kafka-docker

Container solution for Apache Kafka.
Learn more about Apache Kafka in [official documentation](https://kafka.apache.org/).

## Upstream

Build instruction for docker containers partially copied from:
(https://github.com/wurstmeister/kafka-docker)


## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Gitlab.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/kafka).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/kafka3
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/kafka/3/debian10/3.1/)
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Kafka](#running-kafka-docker)
    * [Running Kafka with Zookeeper service](#Runnung-Kafka-with-Zookeeper-service)
    * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-kafka-docker"></a>Running Kafka

This section describes how to spin up a Kafka service using this image.

### <a name="Runnung-Kafka-with-Zookeeper-service)"></a>Running Kafka with Zookeeper service

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  zookeeper:
    container_name: zookeeper
    image: marketplace.gcr.io/google/zookeeper3
    environment:
      - ZOO_4LW_COMMANDS_WHITELIST="*"
  kafka-node-1:
    container_name: kafka-node-1
    image: marketplace.gcr.io/google/kafka3
    ports:
      - 9092:9092
    environment:
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - KAFKA_ADVERTISED_HOST_NAME=kafka-node-1
      - KAFKA_ADVERTISED_PORT=9092
      - KAFKA_PORT=9092
    depends_on:
      - zookeeper
  kafka-node-2:
    container_name: kafka-node-2
    image: marketplace.gcr.io/google/kafka3
    ports:
      - 9093:9092
    environment:
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - KAFKA_ADVERTISED_HOST_NAME=kafka-node-2
      - KAFKA_ADVERTISED_PORT=9092
      - KAFKA_PORT=9092
    depends_on:
      - zookeeper
```

Or you can use `docker run` directly:

```shell
docker network create kafka-network
docker run -d --network kafka-network --hostname zookeeper \
    -e ZOO_4LW_COMMANDS_WHITELIST="*" --name zookeeper \
    marketplace.gcr.io/google/zookeeper3
docker run -d --network kafka-network --hostname kafka-node-1 \
    -p 9092:9092 \
    -e "KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181" \
    -e "KAFKA_ADVERTISED_HOST_NAME=kafka-node-1" \
    -e "KAFKA_ADVERTISED_PORT=9092" -e "KAFKA_PORT=9092" \
    --name kafka-node-1 \
    marketplace.gcr.io/google/kafka3
docker run -d --network kafka-network --hostname kafka-node-2 \
    -p 9093:9092 \
    -e "KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181" \
    -e "KAFKA_ADVERTISED_HOST_NAME=kafka-node-2" \
    -e "KAFKA_ADVERTISED_PORT=9092" -e "KAFKA_PORT=9092" \
    --name kafka-node-2 \
    marketplace.gcr.io/google/kafka3
```

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

```yaml
version: '2'
services:
  zookeeper:
    container_name: zookeeper
    image: marketplace.gcr.io/google/zookeeper3
    environment:
      - ZOO_4LW_COMMANDS_WHITELIST="*"
      - ZK_DATA_DIR=/data
    volumes:
      - /data
  kafka-node-1:
    container_name: kafka-node-1
    image: marketplace.gcr.io/google/kafka3
    restart: always
    ports:
      - 9092:9092
    environment:
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - KAFKA_ADVERTISED_HOST_NAME=kafka-node-1
      - KAFKA_ADVERTISED_PORT=9092
      - KAFKA_PORT=9092
    depends_on:
      - zookeeper
    volumes:
      - /kafka
  kafka-node-2:
    container_name: kafka-node-2
    image: marketplace.gcr.io/google/kafka3
    restart: always
    ports:
      - 9093:9092
    environment:
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - KAFKA_ADVERTISED_HOST_NAME=kafka-node-2
      - KAFKA_ADVERTISED_PORT=9092
      - KAFKA_PORT=9092
    depends_on:
      - zookeeper
    volumes:
      - /kafka
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
| :------- | :-------------- |
| TCP 9092 | Kafka Server    |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.
| **Variable**               | **Description**                                         |
| :------------------------- | :------------------------------------------------------ |
| KAFKA_ZOOKEEPER_CONNECT    | Zookeeper address, mandatory parameter                  |
| KAFKA_ADVERTISED_HOST_NAME | Advertised hostname                                     |
| KAFKA_BROKER_ID            | Broker id, default is 1001                              |
| KAFKA_CREATE_TOPICS        | Automatically create topics, "Topic:Partition:Replicas" |
| KAFKA_ADVERTISED_LISTENERS | List of kafka listeners                                 |

if you want to customize any Kafka parameters, simply add them as environment variables. 
For example in order to increase the message.max.bytes parameter set the environment to KAFKA_MESSAGE_MAX_BYTES: 2000000. 
To turn off automatic topic creation set KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'false'

You can see full list of acceptable parameters on the official [Kafka docs](https://kafka.apache.org/documentation/#brokerconfigs). 

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description** |
| :------- | :-------------- |
| /kafka   | Kafka logs      |

