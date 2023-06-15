# solr-docker

Container solution for Apache Solr.
Learn more about Apache Solr in [official documentation](https://solr.apache.org/guide/solr/latest/index.html).

## Upstream

- Source for [Apache Solr docker solution](https://github.com/docker-solr/docker-solr/)

## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Apache Solr.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/details/google/solr).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/solr9
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/solr/9/debian11/9.1/)
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Solr](#running-solr-docker)
    * [Running Solr in standalone mode](#Runnung-Solr-in-standalone-mode)
    * [Running Solr with Zookeeper service](#Runnung-Solr-with-Zookeeper-service)
    * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-solr-docker"></a>Running Solr

This section describes how to spin up a Solr service using this image.


### <a name="Runnung-Solr-in-standalone-mode"></a>Running Solr in standalone mode

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  solr:
    container_name: solr
    image: marketplace.gcr.io/google/solr9
    ports:
      - 8983:8983
```

Or you can use `docker run` directly:

```shell
docker run -d \
    -p 8983:8983 \
    --name solr \
    marketplace.gcr.io/google/solr9
```

### <a name="Runnung-Solr-with-Zookeeper-service"></a>Running Solr with Zookeeper service

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  zookeeper:
    container_name: zookeeper
    image: marketplace.gcr.io/google/zookeeper3
    environment:
      - ZOO_4LW_COMMANDS_WHITELIST="*"
  solr-node-1:
    container_name: solr-node-1
    image: marketplace.gcr.io/google/solr9
    ports:
      - 8983:8983
    environment:
      - ZK_HOST=zookeeper
    depends_on:
      - zookeeper
  solr-node-2:
    container_name: solr-node-2
    image: marketplace.gcr.io/google/solr9
    ports:
      - 8984:8983
    environment:
      - ZK_HOST=zookeeper
    depends_on:
      - zookeeper
  solr-node-3:
    container_name: solr-node-3
    image: marketplace.gcr.io/google/solr9
    ports:
      - 8985:8983
    environment:
      - ZK_HOST=zookeeper
    depends_on:
      - zookeeper
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
  solr-node-1:
    container_name: solr-node-1
    image: marketplace.gcr.io/google/solr9
    ports:
      - 8983:8983
    environment:
      - ZK_HOST=zookeeper
    depends_on:
      - zookeeper
    volumes:
      - /var/solr/data
      - /var/solr/logs
  solr-node-2:
    container_name: solr-node-2
    image: marketplace.gcr.io/google/solr9
    ports:
      - 8984:8983
    environment:
      - ZK_HOST=zookeeper
    depends_on:
      - zookeeper
    volumes:
      - /var/solr/data
      - /var/solr/logs
  solr-node-3:
    container_name: solr-node-3
    image: marketplace.gcr.io/google/solr9
    ports:
      - 8985:8983
    environment:
      - ZK_HOST=zookeeper
    depends_on:
      - zookeeper
    volumes:
      - /var/solr/data
      - /var/solr/logs
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
| :------- | :-------------- |
| TCP 8983 | Solr Server     |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable**  | **Description**                                              |
| :------------ | :----------------------------------------------------------- |
| SOLR_OPTS     | Pass java arguments, e.g. -Xms512M -Xmx1024M.                |
| ZK_HOST       | Zookeeper address                                            |
| SOLR_HOME     | Home directory with index files, `/var/solr/data` by default |
| SOLR_LOGS_DIR | Logs directory, `/var/solr/logs` by default                  |

You can see full list of acceptable variables on the official [Solr docs](https://solr.apache.org/guide/8_11/taking-solr-to-production.html). 

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path**       | **Description** |
| :------------- | :-------------- |
| /var/solr/data | Solr data       |
| /var/solr/logs | Solr logs       |

