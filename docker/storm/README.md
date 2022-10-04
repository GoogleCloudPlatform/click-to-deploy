# storm-docker

Container solution for Apache Storm.
Learn more about Apache Storm in [official documentation](https://storm.apache.org/).

## Upstream

Build instruction for docker containers partially copied from:
(https://github.com/apache/storm/blob/master/Dockerfile)
and
(https://github.com/amancevice/docker-storm/blob/main/Dockerfile)

## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Apache Storm.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/storm2).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/storm2
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/storm/2/debian11/2.4/)
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Storm](#running-storm-docker)
    * [Running Storm with SQLite](#running-storm-sqlite)
* [References](#references)
  * [Ports](#references-ports)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-storm-docker"></a>Running Storm

This section describes how to spin up an Storm service using this image.

### <a name="running-storm-sqlite"></a>Running Storm with SQLite

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  storm:
    image: marketplace.gcr.io/google/storm2
    ports:
      - 8080:8080
```

Or you can use `docker run` directly:

```shell
docker run -d \
    -p 8080:8080 \
    --name storm \
    marketplace.gcr.io/google/storm2
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description**|
| :------- | :--------------|
| TCP 8080 | Storm UI       |
| TCP 8000 | Storm Logviewer|
| TCP 2181 | Zookeeper      |
| TCP 6628 | Supervisor Port|
| TCP 6627 | Nimbus Port    |

You can see full list of acceptable parameters on the official [Storm docs](https://storm.apache.org/releases/2.4.0/Configuration.html).
