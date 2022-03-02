# zookeeper-docker

Container solution for ZooKeeper.
Learn more about ZooKeeper in [official documentation](https://zookeeper.apache.org/).

## Upstream

- Source for [ZooKeeper 3.5+](https://github.com/31z4/zookeeper-docker)

- Source for [ZooKeeper 3.4](https://github.com/kubernetes-retired/contrib/blob/master/statefulsets/zookeeper/Dockerfile)
- Source for [Exporter](https://github.com/carlpett/zookeeper_exporter)

## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Zookeeper.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/zookeeper).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/zookeeper3
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/zookeeper/3/debian10/3.7/)

=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Zookeeper](#running-zookeeper-docker)
    * [Running Zookeeper standalone](#Running-Zookeeper-standalone)
    * [Running Zookeeper cluster](#Runnung-Zookeeper-cluster)
    * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-zookeeper-docker"></a>Running Zookeeper

This section describes how to spin up a Zookeeper service using this image.

### <a name="Runnung-Zookeeper-standalone"></a>Running Zookeeper standalone

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  zookeeper:
    container_name: zookeeper
    image: marketplace.gcr.io/google/zookeeper3
    ports:
      - 2181:2181
    environment:
      - ZOO_4LW_COMMANDS_WHITELIST="*"
```

Or you can use `docker run` directly:

```shell
docker run -d --hostname zookeeper \
    -p 2181:2181 \
    -e ZOO_4LW_COMMANDS_WHITELIST="*" \
    --name zookeeper \
    marketplace.gcr.io/google/zookeeper3
```


