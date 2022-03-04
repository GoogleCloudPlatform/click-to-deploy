hazelcast-docker
============

Dockerfile source for Hazelcast [docker](https://docker.io) image.

# Upstream
This source repo was originally copied from:
https://github.com/hazelcast/hazelcast-docker
https://github.com/hazelcast/management-center-docker

# Disclaimer
This is not an official Google product.

# <a name="about"></a>About

These images contain an installation of Hazelcast and Hazelcast Management Center.

For more information, see the:

- [Hazelcast Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/hazelcast4).
- [Hazelcast Management Center Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/hazelcast-mc4).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/hazelcast4
docker -- pull marketplace.gcr.io/google/hazelcast-mc4
```
Dockerfiles for this images can be found here:

- [hazelcast4](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/hazelcast/4/debian10/hazelcast4.2/)
- [hazelcast-mc4](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/hazelcast/4/debian10/hazelcast-mc/4.2021.12/)
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Hazelcast](#running-hazelcast-docker)
    * [Running Hazelcast standalone](#Running-Hazelcast-standalone)
    * [Running Hazelcast cluster](#Runnung-Hazelcast-cluster)
    * [Use a persistent data volume docker (Enterprise version only)](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-hazelcast-docker"></a>Running Hazelcast

This section describes how to spin up a Hazelcast service using this image.

### <a name="Runnung-Hazelcast-standalone"></a>Running Hazelcast standalone

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  hazelcast:
    image: marketplace.gcr.io/google/hazelcast4
    ports:
      - 5701:5701
```

Or you can use `docker run` directly:

```shell
docker run -d \
    -p 5701:5701 \
    --name hazelcast \
    marketplace.gcr.io/google/hazelcast4
```

### <a name="Runnung-Hazelcast-cluster"></a>Running Hazelcast cluster

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  hazelcast1:
    container_name: hazelcast1
    restart: always
    hostname: hazelcast1
    image: marketplace.gcr.io/google/hazelcast4
    ports:
      - 5701:5701
    environment:
      - JAVA_OPTS=-Dhazelcast.mancenter.enabled=true -Dhazelcast.mancenter.url=http://hazelcast-mc:8080
  hazelcast2:
    container_name: hazelcast2
    restart: always
    hostname: hazelcast2
    image: marketplace.gcr.io/google/hazelcast4
    ports:
      - 5702:5701
    environment:
      - JAVA_OPTS=-Dhazelcast.mancenter.enabled=true -Dhazelcast.mancenter.url=http://hazelcast-mc:8080
  hazelcast-mc:
    container_name: hazelcast-mc
    restart: always
    hostname: hazelcast-mc
    image: marketplace.gcr.io/google/hazelcast-mc4
    ports:
      - 8080:8080
    environment:
      - MC_INIT_CMD=./bin/mc-conf.sh cluster add -H=/data -ma hazelcast1:5701 -cn dev
    depends_on:
      - hazelcast1
      - hazelcast2
```

Then, access it via [http://localhost:8080](http://localhost:8080) or `http://host-ip:8080` in a browser.

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume (Enterprise version only)

Data in Hazelcast is usually stored in-memory (RAM) so that it’s faster to access. 
However, data in RAM is volatile, meaning that when one or more members shut down, their data is lost. 
When you persist data on disk, members can load it upon a restart and continue to operate as usual.

Read more [here](https://docs.hazelcast.com/hazelcast/latest/storage/configuring-persistence).

```yaml
version: '2'
services:
  hazelcast1:
    container_name: hazelcast1
    restart: always
    hostname: hazelcast1
    image: marketplace.gcr.io/google/hazelcast4
    ports:
      - 5701:5701
    environment:
      - JAVA_OPTS=-Dhazelcast.mancenter.enabled=true -Dhazelcast.mancenter.url=http://hazelcast-mc:8080
      - HZ_LICENSEKEY=<your_license_key>
      - HZ_PERSISTENCE_ENABLED="true"
    volumes:
      - /opt/hazelcast/data
  hazelcast2:
    container_name: hazelcast2
    restart: always
    hostname: hazelcast2
    image: marketplace.gcr.io/google/hazelcast4
    ports:
      - 5702:5701
    environment:
      - JAVA_OPTS=-Dhazelcast.mancenter.enabled=true -Dhazelcast.mancenter.url=http://hazelcast-mc:8080
      - HZ_LICENSEKEY=<your_license_key>
      - HZ_PERSISTENCE_ENABLED="true"
    volumes:
      - /opt/hazelcast/data
  hazelcast-mc:
    container_name: hazelcast-mc
    restart: always
    hostname: hazelcast-mc
    image: marketplace.gcr.io/google/hazelcast-mc4
    ports:
      - 8080:8080
    environment:
      - MC_INIT_CMD=./bin/mc-conf.sh cluster add -H=/data -ma hazelcast1:5701 -cn dev
    depends_on:
      - hazelcast1
      - hazelcast2
    volumes:
      - /data
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description**                |
| :------- | :----------------------------- |
| TCP 5071 | Hazelcast Server.              |
| TCP 8080 | Hazelcast MC http port.        |
| TCP 8081 | Hazelcast MC healthcheck port. |
| TCP 8443 | Hazelcast MC https port.       |
