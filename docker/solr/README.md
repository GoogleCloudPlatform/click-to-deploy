# solr-docker

Container solution for Apache Solr.
Learn more about Apache Solr in [official documentation](https://lucene.apache.org/solr/).

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
docker -- pull marketplace.gcr.io/google/solr8
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/solr/8/debian10/8.11/)
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Solr](#running-solr-docker)
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


version: '2'
services:
  zookeeper:
    container_name: zookeeper
    image: marketplace.gcr.io/google/zookeeper3
    environment:
      - ZOO_4LW_COMMANDS_WHITELIST="*"
  solr:
    container_name: solr
    image: marketplace.gcr.io/google/solr8
    ports:
      - 8983:8983
    environment:
      - ZK_HOST=zookeeper
    depends_on:
      - zookeeper

