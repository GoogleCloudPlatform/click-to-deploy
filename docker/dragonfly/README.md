# Description

Dragonfly is a p2p-based image and file distribution system based on an intelligent scheduling system

# Upstream
This source repo was originally copied from:
https://github.com/dragonflyoss/Dragonfly2

# Disclaimer
This is not an official Google product.

# About

These images contain an installation of Dragonfly2 environment.

For more information, see the:

- [Dragonfly2 documentation](https://d7y.io/docs/)

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/dragonfly2-manager
docker -- pull marketplace.gcr.io/google/dragonfly2-scheduler
docker -- pull marketplace.gcr.io/google/dragonfly2-seed-peer
docker -- pull marketplace.gcr.io/google/dragonfly2-dfget

```
Dockerfiles for this images can be found here:

- [manager](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/dobrucki-dragonfly2-draft/docker/dragonfly2/2/debian11/dragonfly-manager/2.0)
- [scheduler](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/dobrucki-dragonfly2-draft/docker/dragonfly2/2/debian11/dragonfly-scheduler/2.0)
- [seed-peer](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/dobrucki-dragonfly2-draft/docker/dragonfly2/2/debian11/dragonfly-seed-peer/2.0)
- [dfget](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/dobrucki-dragonfly2-draft/docker/dragonfly2/2/debian11/dragonfly-dfget/2.0)

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Dragonfly2 using docker-compose](#running-dragonfly-compose)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-dragonfly-compose"></a>Running Dragonfly2 using docker-compose

Use the following content of `docker-compose.yaml` file, then run `docker-compose up`.

```yaml
version: "3"
services:
  redis:
    image: marketplace.gcr.io/google/redis6
    container_name: redis
    command: >
      --requirepass dragonfly
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "dragonfly", "ping"]
      interval: 1s
      timeout: 2s
      retries: 30
    ports:
      - 6379:6379

  mysql:
    image: marketplace.gcr.io/google/mariadb10
    container_name: mysql
    environment:
      - MARIADB_USER=dragonfly
      - MARIADB_PASSWORD=dragonfly
      - MARIADB_DATABASE=manager
      - MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=yes
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin status"]
      interval: 1s
      timeout: 2s
      retries: 30
    ports:
      - 3306:3306

  manager:
    image: marketplace.gcr.io/google/dragonfly2-manager
    container_name: manager
    environment:
      - DRAGONFLY_MYSQL_USER=dragonfly
      - DRAGONFLY_MYSQL_PW=dragonfly
      - DRAGONFLY_MYSQL_DBNAME=manager
      - DRAGONFLY_MYSQL_HOST=mysql
      - DRAGONFLY_REDIS_HOST=redis
      - DRAGONFLY_REDIS_PW=dragonfly
    depends_on:
      - redis
      - mysql
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "/bin/grpc_health_probe -addr=:65003 || exit 1"]
      interval: 1s
      timeout: 2s
      retries: 30
    ports:
      - 65003:65003
      - 8080:8080

  scheduler:
    image: marketplace.gcr.io/google/dragonfly2-scheduler
    container_name: scheduler
    environment:
      - DRAGONFLY_REDIS_HOST=redis
      - DRAGONFLY_MANAGER_ADDR=manager
    depends_on:
      - manager
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "/bin/grpc_health_probe -addr=:8002 || exit 1"]
      interval: 1s
      timeout: 2s
      retries: 30
    ports:
      - 8002:8002

  seed-peer:
    image: marketplace.gcr.io/google/dragonfly2-seed-peer
    container_name: seed-peer
    environment:
     - DRAGONFLY_MANAGER_ADDR=manager
     - DRAGONFLY_SCHEDULER_ADDR=scheduler
     - DRAGONFLY_SEED_PEER_ADDR=seed-peer
    depends_on:
      - manager
      - scheduler
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "/bin/grpc_health_probe -addr=:65100 || exit 1"]
      interval: 1s
      timeout: 2s
      retries: 30
    ports:
      - 65006:65006
      - 65007:65007
      - 65008:65008

  dfget:
    image: marketplace.gcr.io/google/dragonfly2-dfget
    container_name: peer
    environment:
     - DRAGONFLY_MANAGER_ADDR=manager
     - DRAGONFLY_SCHEDULER_ADDR=scheduler
     - DRAGONFLY_DFGET_ADDR=peer
    depends_on:
      - manager
      - scheduler
      - seed-peer
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "/bin/grpc_health_probe -addr=:65000 || exit 1"]
      interval: 1s
      timeout: 2s
      retries: 30
    ports:
      - 65000:65000
      - 65001:65001
      - 65002:65002
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container images.

| **Port**        | **Description**                | 
| :-------        | :----------------------------- |
| TCP 8080        | Manager Console port.          |
| TCP 65003       | Manager healthcheck port.      |
| TCP 8002        | Scheduler healthcheck port.    |
| TCP 65000-65002 | Dfget listen ports.            |
| TCP 65006-65008 | Seed-peer listen ports.        |  
| TCP 65100       | Seed-peer healthcheck port.    |

## <a name="references-environment-variables"></a>Environment Variables
These are the environment variables understood by the container images.

### Manager

| **Variable**    | **Description**                               |
| :-------------- | :-------------------------------------------- |
| DRAGONFLY_MYSQL_USER   | Username for database. 'dragonfly' by default       |
| DRAGONFLY_MYSQL_PW     | Password for database. 'dragonfly' by default       |
| DRAGONFLY_MYSQL_DBNAME | Database name. 'manager' by default                 |
| DRAGONFLY_MYSQL_HOST   | Adress of database instance. |
| DRAGONFLY_REDIS_PW     | Redis password.             |
| DRAGONFLY_REDIS_HOST   | Address of redis instance.    |

### Scheduler 

| **Variable**    | **Description**                               |
| :-------------- | :-------------------------------------------- |
| DRAGONFLY_REDIS_PW     | Redis password.            |
| DRAGONFLY_REDIS_HOST   | Address of redis instance.   |
| DRAGONFLY_MANAGER_ADDR | Address of dragonfly manager. |

### Seed-peer

| **Variable**    | **Description**                               |
| :-------------- | :-------------------------------------------- |
| DRAGONFLY_MANAGER_ADDR | Address of dragonfly manager. |
| DRAGONFLY_SCHEDULER_ADDR | Address of dragonfly scheduler.|
| DRAGONFLY_SEED_PEER_ADDR | Address of dragonfly seed-peer to advertise |

### Dfget

| **Variable**    | **Description**                               |
| :-------------- | :-------------------------------------------- |
| DRAGONFLY_MANAGER_ADDR | Address of dragonfly manager. |
| DRAGONFLY_SCHEDULER_ADDR | Address of dragonfly scheduler. |
| DRAGONFLY_DFGET_ADDR | Address of dragonfly dfget to advertise |

## <a name="references-volumes"></a>Volumes

| **Path** | **Description**                  |
| :------- | :------------------------------- |
| /var/log/dragonfly | Folder to store logs. |







