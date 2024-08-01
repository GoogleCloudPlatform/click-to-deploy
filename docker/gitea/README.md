gitea-docker
============

Dockerfile source for gitea [docker](https://docker.io) image.

# Upstream
This source repo is based on: https://github.com/go-gitea/gitea.

# Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Gitea.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/gitea).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/gitea
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/gitea/1/debian11/1.16).
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Gitea](#running-gitea-docker)
    * [Running Gitea standalone](#running-gitea-standalone)
    * [Running gitea with PostgreSQL](#running-gitea-with-PostgreSQL)
    * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-gitea-docker"></a>Running gitea

This section describes how to spin up a gitea service using this image.

### <a name="Runnung-gitea-standalone"></a>Running gitea standalone 

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
networks:
  gitea:
    external: false
services:
  server:
    image: marketplace.gcr.io/google/gitea
    container_name: gitea
    environment:
      - USER_UID=1000
      - USER_GID=1000
    restart: always
    networks:
      - gitea
    ports:
      - "3000:3000"
      - "222:22"
```

Or you can use `docker run` directly:

```shell
docker run -d --name 'gitea' -it --rm \
    -p 3000:3000 \
    -p 2222:22 \
    -e USER_GID=1000 \
    -e USER_UID=1000 \
    marketplace.gcr.io/google/gitea
```

Then, access it via [http://localhost:3000](http://localhost:3000) or `http://host-ip:3000` in a browser.

### <a name="Runnung-gitea-with-PostgreSQL"></a>Running gitea with PostgreSQL

Gitea has built-in database but PostgreSQL can be run in external container.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
networks:
  gitea:
    external: false

services:
  server:
    image: marketplace.gcr.io/google/gitea
    container_name: gitea
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - GITEA__database__DB_TYPE=postgres
      - GITEA__database__HOST=db:5432
      - GITEA__database__NAME=gitea
      - GITEA__database__USER=gitea
      - GITEA__database__PASSWD=gitea
    restart: always
    networks:
      - gitea
    ports:
      - "3000:3000"
      - "222:22"
    depends_on:
      - db
  db:
    image: marketplace.gcr.io/google/postgresql14
    restart: always
    environment:
      - POSTGRES_USER=gitea
      - POSTGRES_PASSWORD=gitea
      - POSTGRES_DB=gitea
    networks:
      - gitea
    volumes:
      - ./postgres:/var/lib/postgresql/data
```

Then, access it via [http://localhost:3000](http://localhost:3000) or `http://host-ip:3000` in a browser.

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

```yaml
version: '2'
networks:
  gitea:
    external: false

services:
  server:
    image: marketplace.gcr.io/google/gitea
    container_name: gitea
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - GITEA__database__DB_TYPE=postgres
      - GITEA__database__HOST=db:5432
      - GITEA__database__NAME=gitea
      - GITEA__database__USER=gitea
      - GITEA__database__PASSWD=gitea
    restart: always
    networks:
      - gitea
    volumes:
      - ./gitea:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - "3000:3000"
      - "222:22"
    depends_on:
      - db
  db:
    image: marketplace.gcr.io/google/postgresql14
    restart: always
    environment:
      - POSTGRES_USER=gitea
      - POSTGRES_PASSWORD=gitea
      - POSTGRES_DB=gitea
    networks:
      - gitea
    volumes:
      - ./postgres:/var/lib/postgresql/data
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port**   | **Description**      |
| :--------- | :------------------- |
| TCP 22     | Standard SSH port.   |
| TCP 3000     | Standard HTTP port.  |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable**          | **Description**                     |
| :-------------------- | :---------------------------------- |
| USER_GID | Git user group ID |
| USER_UID | Git user ID |

You can see full list of acceptable parameters on the official [Gitea docs](https://docs.gitea.io/en-us/). 


## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path**        | **Description**                                               |
| :-------------- | :------------------------------------------------------------ |
| /data | Gitea storage with repositories, artifacts, packages, etc... |
