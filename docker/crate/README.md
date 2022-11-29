# crate

Container solution for Crate.
Learn more about Crate in [official documentation](https://crate.io/docs/crate/tutorials/en/latest/).

## Upstream

Build instruction for docker containers partially copied from:
(https://github.com/crate/docker-crate/blob/master/Dockerfile)

## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Crate.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/crate5).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/crate5
```

Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/crate/5/debian11/5.1/)
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Crate](#running-crate-docker)
    * [Running Crate standalone](#Runnung-Crate-standalone)
    * [Running Crate cluster](#Runnung-Crate-cluster)
    * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-crate-docker"></a>Running Crate

This section describes how to spin up an Crate service using this image.

### <a name="Runnung-Crate-standalone"></a>Running Crate standalone

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
---
version: '3'
services:
  crate01:
    image: marketplace.gcr.io/google/crate5
    ports:
      - 4200:4200
      - 5432:5432
    command:
      - "crate"
      - "-Cdiscovery.type=single-node"
    restart: on-failure
```

Or you can use `docker run` directly:

```shell
docker run --name crate01 -p 4200:4200 -p 5432:5432 -d marketplace.gcr.io/google/crate5 crate -Cdiscovery.type=single-node 
```

### <a name="Runnung-Crate-cluster"></a>Running Crate cluster

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
---
version: '3'
services:
  crate01:
    image: marketplace.gcr.io/google/crate5
    ports:
      - "4201:4200"
    command: ["crate",
              "-Ccluster.name=crate-docker-cluster",
              "-Cnode.name=crate01",
              "-Cnode.data=true",
              "-Cnetwork.host=_site_",
              "-Cdiscovery.seed_hosts=crate02,crate03",
              "-Ccluster.initial_master_nodes=crate01,crate02,crate03",
              "-Cgateway.expected_data_nodes=3",
              "-Cgateway.recover_after_data_nodes=2"]
    restart: on-failure
    environment:
      - CRATE_HEAP_SIZE=2g

  crate02:
    image: marketplace.gcr.io/google/crate5
    ports:
      - "4202:4200"
    command: ["crate",
              "-Ccluster.name=crate-docker-cluster",
              "-Cnode.name=crate02",
              "-Cnode.data=true",
              "-Cnetwork.host=_site_",
              "-Cdiscovery.seed_hosts=crate01,crate03",
              "-Ccluster.initial_master_nodes=crate01,crate02,crate03",
              "-Cgateway.expected_data_nodes=3",
              "-Cgateway.recover_after_data_nodes=2"]
    restart: on-failure
    environment:
      - CRATE_HEAP_SIZE=2g

  crate03:
    image: marketplace.gcr.io/google/crate5 
    ports:
      - "4203:4200"
    command: ["crate",
              "-Ccluster.name=crate-docker-cluster",
              "-Cnode.name=crate03",
              "-Cnode.data=true",
              "-Cnetwork.host=_site_",
              "-Cdiscovery.seed_hosts=crate01,crate02",
              "-Ccluster.initial_master_nodes=crate01,crate02,crate03",
              "-Cgateway.expected_data_nodes=3",
              "-Cgateway.recover_after_data_nodes=2"]
    restart: on-failure
    environment:
      - CRATE_HEAP_SIZE=2g
```

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

```yaml
---
version: '3'
services:
  crate01:
    image: marketplace.gcr.io/google/crate5
    ports:
      - "4201:4200"
    volumes:
      - crate01:/data
    command: ["crate",
              "-Ccluster.name=crate-docker-cluster",
              "-Cnode.name=crate01",
              "-Cnode.data=true",
              "-Cnetwork.host=_site_",
              "-Cdiscovery.seed_hosts=crate02,crate03",
              "-Ccluster.initial_master_nodes=crate01,crate02,crate03",
              "-Cgateway.expected_data_nodes=3",
              "-Cgateway.recover_after_data_nodes=2"]
    restart: on-failure
    environment:
      - CRATE_HEAP_SIZE=2g

  crate02:
    image: marketplace.gcr.io/google/crate5
    ports:
      - "4202:4200"
    volumes:
      - crate02:/data
    command: ["crate",
              "-Ccluster.name=crate-docker-cluster",
              "-Cnode.name=crate02",
              "-Cnode.data=true",
              "-Cnetwork.host=_site_",
              "-Cdiscovery.seed_hosts=crate01,crate03",
              "-Ccluster.initial_master_nodes=crate01,crate02,crate03",
              "-Cgateway.expected_data_nodes=3",
              "-Cgateway.recover_after_data_nodes=2"]
    restart: on-failure
    environment:
      - CRATE_HEAP_SIZE=2g

  crate03:
    image: marketplace.gcr.io/google/crate5 
    ports:
      - "4203:4200"
    volumes:
      - crate03:/data
    command: ["crate",
              "-Ccluster.name=crate-docker-cluster",
              "-Cnode.name=crate03",
              "-Cnode.data=true",
              "-Cnetwork.host=_site_",
              "-Cdiscovery.seed_hosts=crate01,crate02",
              "-Ccluster.initial_master_nodes=crate01,crate02,crate03",
              "-Cgateway.expected_data_nodes=3",
              "-Cgateway.recover_after_data_nodes=2"]
    restart: on-failure
    environment:
      - CRATE_HEAP_SIZE=2g
volumes:
  crate01:
  crate02:
  crate03:
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description**            |
| :------- | :------------------------- |
| TCP 4200 | CrateDB Admin UI           |
| TCP 4300 | CrateDB Transport Protocol |
| TCP 5432 | PostgreSQL Wire Protocol   |
| TCP 7071 | Prometheus metrics         |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.
| **Variable**         | **Description**                                                |
| :------------------- | :------------------------------------------------------------- |
| CRATE_JAVA_OPTS      | The Java options to use when running CrateDB                   |
| CRATE_HEAP_SIZE      | The Java heap size                                             |
| CRATE_HEAP_DUMP_PATH | The directory to be used for heap dumps in the case of a crash |

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description**  |
| :------- | :--------------- |
| /data    | Default data dir |


