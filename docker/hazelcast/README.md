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

- [Hazelcast Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/hazelcast5).
- [Hazelcast Management Center Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/hazelcast-mc5).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/hazelcast5
docker -- pull marketplace.gcr.io/google/hazelcast-mc5
```
Dockerfiles for this images can be found here:

- [hazelcast5](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/hazelcast/5/debian11/hazelcast5.2/)
- [hazelcast-mc5](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/hazelcast/5/debian11/hazelcast-mc/5/)

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
    image: marketplace.gcr.io/google/hazelcast5
    ports:
      - 5701:5701
```

Or you can use `docker run` directly:

```shell
docker run -d \
    -p 5701:5701 \
    --name hazelcast \
    marketplace.gcr.io/google/hazelcast5
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
    image: marketplace.gcr.io/google/hazelcast5
    ports:
      - 5701:5701
    environment:
      - JAVA_OPTS=-Dhazelcast.mancenter.enabled=true -Dhazelcast.mancenter.url=http://hazelcast-mc:8080
  hazelcast2:
    container_name: hazelcast2
    restart: always
    hostname: hazelcast2
    image: marketplace.gcr.io/google/hazelcast5
    ports:
      - 5702:5701
    environment:
      - JAVA_OPTS=-Dhazelcast.mancenter.enabled=true -Dhazelcast.mancenter.url=http://hazelcast-mc:8080
  hazelcast-mc:
    container_name: hazelcast-mc
    restart: always
    hostname: hazelcast-mc
    image: marketplace.gcr.io/google/hazelcast-mc5
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
    image: marketplace.gcr.io/google/hazelcast5
    ports:
      - 5701:5701
    environment:
      - JAVA_OPTS=-Dhazelcast.mancenter.enabled=true -Dhazelcast.mancenter.url=http://hazelcast-mc:8080
      - HZ_LICENSEKEY=<your_license_key>
      - HZ_PERSISTENCE_ENABLED="true"
  hazelcast2:
    container_name: hazelcast2
    restart: always
    hostname: hazelcast2
    image: marketplace.gcr.io/google/hazelcast5
    ports:
      - 5702:5701
    environment:
      - JAVA_OPTS=-Dhazelcast.mancenter.enabled=true -Dhazelcast.mancenter.url=http://hazelcast-mc:8080
      - HZ_LICENSEKEY=<your_license_key>
      - HZ_PERSISTENCE_ENABLED="true"
  hazelcast-mc:
    container_name: hazelcast-mc
    restart: always
    hostname: hazelcast-mc
    image: marketplace.gcr.io/google/hazelcast-mc5
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

These are the ports exposed by the container images.

| **Port** | **Description**                |
| :------- | :----------------------------- |
| TCP 5071 | Hazelcast Server.              |
| TCP 8080 | Hazelcast MC http port.        |
| TCP 8081 | Hazelcast MC healthcheck port. |
| TCP 8443 | Hazelcast MC https port.       |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container images.

### Hazelcast

| **Variable**    | **Description**                               |
| :-------------- | :-------------------------------------------- |
| HZ_LICENSEKEY   | Enterprise License key.                       |
| JAVA_OPTS       | Pass java arguments, e.g. -Xms512M -Xmx1024M. |
| PROMETHEUS_PORT | The port of the JMX Prometheus agent.         |
| LOGGING_LEVEL   | Logging level.                                |

Configuration entries of your cluster can be overritten without changing the declarative configuration files (XML/YAML), see [Overriding Configuration documentation section](https://docs.hazelcast.org/docs/latest/manual/html-single/#overriding-configuration).

Assume that you want to have the following configuration for your cluster, represented as YAML:
```yaml
hazelcast:
  cluster-name: dev
  network:
    port:
      auto-increment: true
      port-count: 100
      port: 5701
```

If you want to use the environment variables, the above would be represented as a set of the following environment variables:
```shell
docker run -d \
    -p 5701:5701 \
    --name hazelcast \ 
    -e HZ_CLUSTERNAME=dev \
    -e HZ_NETWORK_PORT_AUTOINCREMENT=true \
    -e HZ_NETWORK_PORT_PORTCOUNT=100 \
    -e HZ_NETWORK_PORT_PORT=5701 \
    marketplace.gcr.io/google/hazelcast5
```

### Hazelcast Management center

| **Variable**      | **Description**                                       |
| :---------------- | :---------------------------------------------------- |
| MC_LICENSEKEY     | Enterprise License key.                               |
| JAVA_OPTS         | Pass java arguments, e.g. -Xms512M -Xmx1024M.         |
| MC_HTTP_PORT      | Http port, 8080 by default.                           |
| MC_HTTPS_PORT     | HTTPS port, 8443 by default.                          |
| MC_CONTEXT_PATH   | UI path, / by default.                                |
| MC_ADMIN_USER     | Admin login.                                          |
| MC_ADMIN_PASSWORD | Admin password.                                       |
| MC_INIT_CMD       | Execute one or more commands separated by semicolons. |
| MC_INIT_SCRIPT    | Execute a script in Bash syntax.                      |

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description**                  |
| :------- | :------------------------------- |
| /data    | Folder to store persistent data. |

