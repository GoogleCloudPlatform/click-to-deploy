#gogs

Container solution for Gogs.
Learn more about Gogs in [official documentation](https://gogs.io/docs/installation/configuration_and_run).

## Upstream

Build instruction for docker containers partially copied from:
(https://github.com/gogs/gogs/blob/main/Dockerfile)

## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Gogs.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/gogs0).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/gogs0
```

Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/gogs/0/debian11/0.12/)
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Gogs](#running-gogs-docker)
    * [Running Gogs standalone](#Runnung-Gogs-standalone)
    * [Running Gogs with PostgreSQL](#Runnung-Gogs-with-PostgreSQL)
    * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-gogs-docker"></a>Running Gogs

This section describes how to spin up an Tikv service using this image.

### <a name="Runnung-Gogs-standalone"></a>Running Gogs standalone

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
---
version: '3'
services:
  gogs:
    container_name: gogs
    restart: always
    image: marketplace.gcr.io/google/gogs0
    ports:
      - "3000:3000"
```

Or you can use `docker run` directly:

```shell
docker run --name gogs -p 3000:3000 -d marketplace.gcr.io/google/gogs0
```

### <a name="Runnung-Gogs-with-PostgreSQL"></a>Running Gogs with PostgreSQL

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
---
version: '3'
services:
  postgres:
    image: marketplace.gcr.io/google/postgresql13
    environment:
      POSTGRES_USER: gogs
      POSTGRES_PASSWORD: gogs
      POSTGRES_DB: gogs
    restart: always

  gogs:
    container_name: gogs
    restart: always
    image: gogs-test
    environment:
      GOGS_DB_TYPE: postgres
      GOGS_DB_HOST: postgres:5432
      GOGS_DB_NAME: gogs
      GOGS_DB_USER: gogs
      GOGS_DB_PASSWORD: gogs
    ports:
      - "3000:3000"
    depends_on:
      - postgres
```

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

```yaml
---
version: '3'
services:
  postgres:
    image: marketplace.gcr.io/google/postgresql13
    environment:
      POSTGRES_USER: gogs
      POSTGRES_PASSWORD: gogs
      POSTGRES_DB: gogs
    volumes:
      - postgres-db-volume:/var/lib/postgresql/data
   restart: always

  gogs:
    container_name: gogs
    restart: always
    image: gogs-test
    environment:
      GOGS_DB_TYPE: postgres
      GOGS_DB_HOST: postgres:5432
      GOGS_DB_NAME: gogs
      GOGS_DB_USER: gogs
      GOGS_DB_PASSWORD: gogs
    ports:
      - "3000:3000"
    volumes:
      - "gogs-data:/data/gogs"
      - "git-repo:/data/git/gogs-repositories"
    depends_on:
      - postgres

volumes:
  postgres-db-volume:
  gogs-data:
  git-repo:
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

This is the port exposed by the container image.

| **Port**  | **Description**  |
| :-------- | :--------------- |
| TCP 3000    | Gogs HTTP port |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.
| **Variable**      | **Description**                                            |
| :---------------- | :--------------------------------------------------------- |
| GOGS_CUSTOM       | Path to the Gogs data folder                               |
| GOGS_DB_TYPE      | Used DB type - internal `sqlite3` or `postgres`.           |
| GOGS_DB_HOST      | Connection string in the format `dbhostname:port`          |
| GOGS_DB_NAME      | DB name                                                    |
| GOGS_DB_USER      | DB username                                                |
| GOGS_DB_PASSWORD  | DB password                                                |
| GOGS_SECRET_KEY   | Secret key for encrypting internal data                    |
| GOGS_DOMAIN       | Gogs domain, `localhost` by default                        |
| GOGS_EXTERNAL_URL | Gogs full external url, `http://localhost:3000` by default |


## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path**     | **Description**      |
| :----------- | :------------------- |
| /data/gogs   | Gogs config and logs |
| /data/git    | Git repositories     |
| /backup      | Gogs backups         |


