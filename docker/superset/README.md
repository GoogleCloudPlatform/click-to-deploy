# superset-docker

Container solution for Apache Superset.
Learn more about Apache Superset in [official documentation](https://superset.apache.org/).

## Upstream

Build instruction for docker containers partially copied from:
(https://github.com/apache/superset/blob/master/Dockerfile)
and
(https://github.com/amancevice/docker-superset/blob/main/Dockerfile)

## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Apache Superset.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/superset2).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/superset2
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/superset/1/debian11/1.5/)
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Superset](#running-superset-docker)
    * [Running Superset with SQLite](#running-superset-sqlite)
    * [Running Superset with additional parameters](#running-superset-with-additional-parameters)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-superset-docker"></a>Running Superset

This section describes how to spin up an Superset service using this image.

### <a name="running-superset-sqlite"></a>Running Superset with SQLite

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  superset:
    image: marketplace.gcr.io/google/superset2
    ports:
      - 8088:8088
```

Or you can use `docker run` directly:

```shell
docker run -d \
    -p 8088:8088 \
    --name superset \
    marketplace.gcr.io/google/superset2
```

### <a name="running-superset-with-additional-parameters"></a>Running Superset with additional parameters

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.


```yaml
version: '2'
services:
  superset:
    image: marketplace.gcr.io/google/superset2
    ports:
      - 8088:8088
    environment:
      SUPERSET_PASSWORD: superset/some-password
      SUPERSET_LOAD_EXAMPLES: yes
```

Or you can use `docker run` directly:

```shell
docker run -d \
    -p 8088:8088 \
    --name superset \
    -e SUPERSET_PASSWORD="superset/some-password" \
    marketplace.gcr.io/google/superset2
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description**|
| :------- | :--------------|
| TCP 8088 | Superset UI    |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.
| **Variable**                  | **Description**                                          |
| :---------------------------- | :------------------------------------------------------- |
| SUPERSET_PASSWORD             | Sets password for Admin user while initializing Superset |
| SUPERSET_LOAD_EXAMPLES        | Installs dashboards examples.                            |
|

You can see full list of acceptable parameters on the official [Superset docs](https://superset.apache.org/docs/installation/configuring-superset/).
