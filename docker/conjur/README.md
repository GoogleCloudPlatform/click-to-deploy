#conjur

Container solution for Conjur.
Learn more about Conjur in [official documentation](https://www.conjur.org/get-started/quick-start/oss-environment/).

## Upstream

Build instruction for docker containers partially copied from:
(https://github.com/cyberark/conjur/blob/master/Dockerfile)

## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Conjur.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/conjur1).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/conjur1
```

Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/conjur/1/debian11/1.18/)
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Conjur](#running-conjur-docker)
    * [Running Conjur with PostgreSQL](#Runnung-Conjur-with-PostgreSQL)
    * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-conjur-docker"></a>Running Conjur

This section describes how to spin up an Tikv service using this image.

### <a name="Runnung-Conjur-with-PostgreSQL"></a>Running Conjur with PostgreSQL

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

## <a name="conjur-cli"></a>Conjur CLI

Conjur CLI Client implements the [REST API](https://docs.conjur.org/Latest/en/Content/Developer/lp_REST_API.htm), providing an alternate interface for managing Conjur resources, including roles, 
privileges, policy, and secrets. You can start a CLI client session as a container local to the Conjur appliance, or remotely on a workstation. 
Conjur CLI cannot be included in a container image due to licensing restrictions. 
If it is necessary to use, install it according to the [official documentation](https://docs.cyberark.com/Product-Doc/OnlineHelp/AAM-DAP/12.4/en/Content/Developer/CLI/cli-setup.htm).
