ActiveMQ-docker
============
Dockerfile source for ActiveMQ [docker](https://docker.io) image..

## Upstream
This source repo was originally copied from:


## Disclaimer
This is not an official Google product.

## About
This image contains an installation of ActiveMQ

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/bitnami-launchpad/activemq).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/activemq5
```
## Table of Contents

 [Using Docker](#using-docker)
  * [Run a  server](#run-a-activemq-server-docker)
    * [Start an activemq instance](#start-a-activemq-instance-docker)
* [References](#references)
  * [Ports](#references-ports)

# Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## Create and set ownership of `data/` directory to `activemq` user.
```shell
mkdir data/
chown 1000:1000 data/
```
## Start an activemq instance

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  activemq:
    container_name: activemq
    image: marketplace.gcr.io/google/activemq5:5.15
    environment:
      - ACTIVEMQ_ADMIN_PASSWORD=some-password
    ports:
      - "5672:5672"
      - "61613:61613"
      - "1883:1883"
      - "61614:61614"
      - "8161:8161"
    volumes:
      - ./data/:/opt/activemq/data
  ```
  
Or you can use `docker run` directly:

```shell
docker run -e ACTIVEMQ_ADMIN_PASSWORD="some-password" \
    --name='activemq' -it --rm \
    -p 5672:5672 \
    -p 61613:61613 \
    -p 1883:1883 \
    -p 61614:61614 \
    -p 8161:8161 \
    -v $PWD/data/:/opt/activemq/data \
    marketplace.gcr.io/google/activemq5:5.15
```
Default admin username is ```admin```
ActiveMQ WebConsole available at http://127.0.0.1:8161

## Ports

| **Port** | **Description** |
|:-------------|:----------------|
|61616 |J MS|
|8161 | UI|
|5672 | AMQP|  
|61613 | STOMP|
|1883 | MQTT|  
|61614 | WS|    

For more information about ActiveMQ, visit [official documentation](https://activemq.apache.org/).

