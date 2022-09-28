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
    volumes:
      - "gogs-data:/data/gogs"
      - "git-repo:/data/git/gogs-repositories"
volumes:
    gogs-data:
    git-repo:
```


### <a name="Runnung-Gogs-with-PostgreSQL"></a>Running Conjur with PostgreSQL

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
---
version: '3'
services:
  postgres:
    image: marketplace.gcr.io/google/postgresql13
    environment:
      POSTGRES_USER: conjur
      POSTGRES_PASSWORD: conjur
      POSTGRES_DB: conjur
    restart: always

  conjur:
    image: marketplace.gcr.io/google/conjur1
    container_name: conjur_server
    environment:
      DATABASE_URL: postgres://conjur:conjur@postgres/conjur
    depends_on:
    - postgres
    restart: on-failure
    ports:
      - 8080:80
```

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

```yaml
---
version: '3'
services:
  postgres:
    image: marketplace.gcr.io/google/postgresql13
    environment:
      POSTGRES_USER: conjur
      POSTGRES_PASSWORD: conjur
      POSTGRES_DB: conjur
    volumes:
      - postgres-db-volume:/var/lib/postgresql/data
   restart: always

  conjur:
    image: marketplace.gcr.io/google/conjur1
    container_name: conjur_server
    environment:
      DATABASE_URL: postgres://conjur:conjur@postgres/conjur
    depends_on:
    - postgres
    restart: on-failure
    ports:
      - 8080:80

volumes:
  postgres-db-volume:

```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

This is the port exposed by the container image.

| **Port**  | **Description**  |
| :-------- | :--------------- |
| TCP 80    | Conjur HTTP port |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.
| **Variable**    | **Description**                                                                                  |
| :-------------- | :----------------------------------------------------------------------------------------------- |
| DATABASE_URL    | Postgres connection string in the format `postgres://username[:password]@database[:port]/dbname` |
| CONJUR_DATA_KEY | 32 bytes, base64 encrypted. Can be generated with the `openssl rand -base64 32` command          |

## <a name="references-volumes"></a>Volumes

Conjur doesn't store any files, instead you should persist your PostgreSQL database.

