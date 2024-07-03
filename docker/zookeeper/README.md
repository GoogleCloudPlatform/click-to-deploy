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
      - ZOO_4LW_COMMANDS_WHITELIST=*
```

Or you can use `docker run` directly:

```shell
docker run -d --hostname zookeeper \
    -p 2181:2181 \
    -e ZOO_4LW_COMMANDS_WHITELIST="*" \
    --name zookeeper \
    marketplace.gcr.io/google/zookeeper3
```

### <a name="Runnung-Zookeeper-cluster"></a>Running Zookeeper cluster

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  zookeeper1:
    container_name: zookeeper1
    restart: always
    image: marketplace.gcr.io/google/zookeeper3
    hostname: zookeeper1
    ports:
      - 2181:2181
    environment:
      - ZOO_4LW_COMMANDS_WHITELIST=*
      - ZOO_MY_ID=1
      - ZOO_SERVERS=server.1=zookeeper1:2888:3888;2181 server.2=zookeeper2:2888:3888;2181 server.3=zookeeper3:2888:3888;2181
  zookeeper2:
    container_name: zookeeper2
    restart: always
    image: marketplace.gcr.io/google/zookeeper3
    hostname: zookeeper2
    ports:
      - 2182:2181
    environment:
      - ZOO_4LW_COMMANDS_WHITELIST=*
      - ZOO_MY_ID=2
      - ZOO_SERVERS=server.1=zookeeper1:2888:3888;2181 server.2=zookeeper2:2888:3888;2181 server.3=zookeeper3:2888:3888;2181
  zookeeper3:
    container_name: zookeeper3
    restart: always
    image: marketplace.gcr.io/google/zookeeper3
    hostname: zookeeper3
    ports:
      - 2183:2181
    environment:
      - ZOO_4LW_COMMANDS_WHITELIST=*
      - ZOO_MY_ID=3
      - ZOO_SERVERS=server.1=zookeeper1:2888:3888;2181 server.2=zookeeper2:2888:3888;2181 server.3=zookeeper3:2888:3888;2181
```

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

```yaml
version: '2'
services:
  zookeeper1:
    container_name: zookeeper1
    restart: always
    image: marketplace.gcr.io/google/zookeeper3
    hostname: zookeeper1
    ports:
      - 2181:2181
    environment:
      - ZOO_4LW_COMMANDS_WHITELIST=*
      - ZOO_MY_ID=1
      - ZOO_SERVERS=server.1=zookeeper1:2888:3888;2181 server.2=zookeeper2:2888:3888;2181 server.3=zookeeper3:2888:3888;2181
    volumes:
      - /data
      - /datalog
  zookeeper2:
    container_name: zookeeper2
    restart: always
    image: marketplace.gcr.io/google/zookeeper3
    hostname: zookeeper2
    ports:
      - 2182:2181
    environment:
      - ZOO_4LW_COMMANDS_WHITELIST=*
      - ZOO_MY_ID=2
      - ZOO_SERVERS=server.1=zookeeper1:2888:3888;2181 server.2=zookeeper2:2888:3888;2181 server.3=zookeeper3:2888:3888;2181
    volumes:
      - /data
      - /datalog
  zookeeper3:
    container_name: zookeeper3
    restart: always
    image: marketplace.gcr.io/google/zookeeper3
    hostname: zookeeper3
    ports:
      - 2183:2181
    environment:
      - ZOO_4LW_COMMANDS_WHITELIST=*
      - ZOO_MY_ID=3
      - ZOO_SERVERS=server.1=zookeeper1:2888:3888;2181 server.2=zookeeper2:2888:3888;2181 server.3=zookeeper3:2888:3888;2181
    volumes:
      - /data
      - /datalog
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description**        |
| :------- | :--------------------- |
| TCP 2181 | Zookeeper Server.      |
| TCP 2888 | Zookeeper peer port.   |
| TCP 3888 | Zookeeper leader port. |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable**                  | **Description**                                                                     |
| :---------------------------- | :---------------------------------------------------------------------------------- |
| ZOO_CONF_DIR                  | Path to the config folder, /conf by default.                                        |
| ZOO_DATA_DIR                  | Path to the data folder, /data by default.                                          |
| ZOO_DATA_LOG_DIR              | Path to the transaction logs folder, /datalog by default.                           |
| ZOO_LOG_DIR                   | Path to the logs folder, /logs by default.                                          |
| ZOO_TICK_TIME                 | The length of a single tick.                                                        |
| ZOO_INIT_LIMIT                | Amount of time, in ticks, to allow followers to connect and sync to a leader.       |
| ZOO_SYNC_LIMIT                | Amount of time, in ticks (see tickTime), to allow followers to sync with Zookeeper. |
| ZOO_AUTOPURGE_PURGEINTERVAL   | Interval in hours to run purge tasks.                                               |
| ZOO_AUTOPURGE_SNAPRETAINCOUNT | Amount of recent snapshots to purge.                                                |
| ZOO_MAX_CLIENT_CNXNS          | Amount of recent snapshots to purge.                                                |
| ZOO_STANDALONE_ENABLED        | POssibility of run in standalone mode.                                              |
| ZOO_ADMINSERVER_ENABLED       | Amount of recent snapshots to purge.                                                |
| ZOO_MY_ID                     | The id must be unique within the ensemble.                                          |
| ZOO_SERVERS                   | The list of machines of the Zookeeper ensemble.                                     |
| ZOO_CFG_EXTRA                 | Additional configuration.                                                           |

You can see full list of acceptable parameters on the official [Zookeeper docs](https://zookeeper.apache.org/doc/r3.4.14/zookeeperAdmin.html).

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description**          |
| :------- | :----------------------- |
| /data    | Data folder.             |
| /datalog | Transaction logs folder. |
| /logs    | Logs folder.             |


