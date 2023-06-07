# keycloak-readme

Container solution for Keycloak.
Learn more about Keycloak in [official documentation](https://www.keycloak.org/guides/).

## Upstream

Build instruction for docker containers partially copied from:
(https://github.com/keycloak/keycloak/blob/main/quarkus/container/Dockerfile).


## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Keycloak.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/keycloak20).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/keycloak20
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/keycloak/18/debian11/18.0/).
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Keycloak](#running-keycloak-docker)
    * [Running Keycloak standalone](#Runnung-Keycloak-standalone)
    * [Running Keycloak with PostgreSQL service](#Runnung-Keycloak-with-PostgreSQL)
    * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-keycloak-docker"></a>Running Keycloak

This section describes how to spin up an Keycloak service using this image.

### <a name="Runnung-Keycloak-standalone"></a>Running Keycloak standalone

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
---
version: '3'
services:
  keycloak:
    image: marketplace.gcr.io/google/keycloak21
    command: start-dev
    ports:
      - 8080:8080
    environment:
      - KEYCLOAK_ADMIN=admin
      - KEYCLOAK_ADMIN_PASSWORD=admin
      - KC_DB=dev-mem
```

Or you can use `docker run` directly:

```shell
docker run -d -p 8080:8080 \
    --name keycloak \
    -e KEYCLOAK_ADMIN=admin \
    -e KEYCLOAK_ADMIN_PASSWORD=admin \
    -e KC_DB=dev-mem \
    marketplace.gcr.io/google/keycloak21 \
    start-dev
```

### <a name="Runnung-Keycloak-with-PostgreSQL"></a>Running Keycloak with PostgreSQL service

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
---
version: '3'

services:
  postgres:
    image: marketplace.gcr.io/google/postgresql13
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: password
  keycloak:
    image: marketplace.gcr.io/google/keycloak21
    command: start-dev
    environment:
        KC_DB_URL: jdbc:postgresql://postgres:5432/keycloak
        KC_DB_USERNAME: keycloak
        KC_DB_PASSWORD: password
        KEYCLOAK_ADMIN: admin
        KEYCLOAK_ADMIN_PASSWORD: password
    ports:
      - 8080:8080
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
    volumes:
      - postgres-db-volume:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: password
  keycloak:
    image: marketplace.gcr.io/google/keycloak20
    volumes:
      - keycloak-data-volume:/opt/keycloak/data
    command: start-dev
    environment:
        KC_DB_URL: jdbc:postgresql://postgres:5432/keycloak
        KC_DB_USERNAME: keycloak
        KC_DB_PASSWORD: password
        KEYCLOAK_ADMIN: admin
        KEYCLOAK_ADMIN_PASSWORD: password
    ports:
      - 8080:8080
    depends_on:
      - postgres
volumes:
  postgres-db-volume:
  keycloak-data-volume:
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description**     |
| :------- | :------------------ |
| TCP 8080 | Keycloak HTTP port  |
| TCP 8443 | Keycloak HTTPS port |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable**            | **Description**                                                              |
| :---------------------- | :--------------------------------------------------------------------------- |
| KC_DB                   | Use chosen DB provider                                                       |
| KEYCLOAK_ADMIN          | Keycloak admin's username                                                    |
| KEYCLOAK_ADMIN_PASSWORD | Keycloak admin's password                                                    |
| KC_DB_URL               | Connection string in the format `jdbc:provider://dbhostname:port/database`   |
| KC_DB_USERNAME          | DB username                                                                  |
| KC_DB_PASSWORD          | DB password                                                                  |
| KC_HOSTNAME             | Keycloak hostname for production mode                                        |
| KC_HOSTNAME_STRICT      | Disable hostname verification if set to false                                |
| KC_HTTP_ENABLED         | Set to `true` in case of using reverse proxy with TLS                        |
| KC_HEALTH_ENABLED       | Expose health endopints at the `/health`, `/health/ready` and `/health/live` |
| KC_METRICS_ENABLED      | Expose `/metrics` endpoint                                                   |

You can see full list of acceptable parameters on the official [Keycloak docs](https://www.keycloak.org/server/all-config). 

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path**             | **Description** |
| :------------------- | :-------------- |
| /opt/keycloak/data   | Keycloak data   |

