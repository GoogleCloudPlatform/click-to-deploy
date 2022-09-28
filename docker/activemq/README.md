activemq-docker
============
Dockerfile source for ActiveMQ [docker](https://docker.io) image.

# Disclaimer
This is not an official Google product.

# <a name="about"></a>About
This image contains an installation of ActiveMQ

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/activemq5).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/activemq5
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/activemq/5/debian9/5.17).
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running ActiveMQ](#running-activemq-docker)
    * [Run a  server](#run-a-server)
    * [Start an activemq instance](#start-a-activemq-instance-docker)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-activemq-docker"></a>Running ActiveMQ

### <a name="run-a-server"></a> Run a server

Create and set ownership of `data/` directory to `activemq` user.

```shell
mkdir data/
chown 1000:1000 data/
```

### <a name="start-a-activemq-instance-docker"></a> Start an ActiveMQ instance

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  activemq:
    container_name: activemq
    image: marketplace.gcr.io/google/activemq5
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
    marketplace.gcr.io/google/activemq5
```
Default admin username is `admin`

ActiveMQ WebConsole available at `http://127.0.0.1:8161`

# <a name="references"></a> References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
|:-------------|:----------------|
|61616 | JMS |
|8161 | UI |
|5672 | AMQP |
|61613 | STOMP |
|1883 | MQTT |
|61614 | WS |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable** | **Description** |
|:-------------|:----------------|
|ACTIVEMQ_ADMIN_PASSWORD| Password for admin user. |

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description** |
|:---------|:----------------|
|/opt/activemq/data| All ActiveMQ files are installed here. |
