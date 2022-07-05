# tikv

Container solution for Tikv.
Learn more about Tikv in [official documentation](https://tikv.org/).

## Upstream

Build instruction for docker containers partially copied from:
(https://github.com/tikv/tikv/blob/release-5.3/Dockerfile)

## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Tikv.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/tikv5).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/tikv5
```

Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/tikv/5/debian11/5.3/)
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Tikv](#running-tikv-docker)
    * [Running Tikv standalone](#Runnung-Tikv-standalone)
    * [Running Tikv cluster](#Runnung-Tikv-cluster)
    * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-tikv-docker"></a>Running Tikv

This section describes how to spin up an Tikv service using this image.

### <a name="Runnung-Tikv-standalone"></a>Running Tikv standalone

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
---
version: '3'

services:
  pd:
    image: marketplace.gcr.io/google/tikv5
    ports:
      - 2379:2379
    command:
      - /pd-server
      - --name=pd
      - --client-urls=http://0.0.0.0:2379
      - --peer-urls=http://0.0.0.0:2380
      - --advertise-client-urls=http://pd:2379
      - --advertise-peer-urls=http://pd:2380
    restart: on-failure
  
  tikv:
    image: marketplace.gcr.io/google/tikv5
    ports:
      - 20160:20160
    command:
      - /tikv-server
      - --addr=0.0.0.0:20160
      - --advertise-addr=tikv:20160
      - --pd=pd:2379
    depends_on:
      - pd
    restart: on-failure
```

### <a name="Runnung-Tikv-cluster"></a>Running Tikv cluster

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
---
version: '3'

services:
  pd0:
    image: marketplace.gcr.io/google/tikv5
    ports:
      - 2379:2379
    command:
      - /pd-server
      - --name=pd0
      - --client-urls=http://0.0.0.0:2379
      - --peer-urls=http://0.0.0.0:2380
      - --advertise-client-urls=http://pd0:2379
      - --advertise-peer-urls=http://pd0:2380
      - --initial-cluster=pd0=http://pd0:2380,pd1=http://pd1:2380,pd2=http://pd2:2380
    restart: on-failure

  pd1:
    image: marketplace.gcr.io/google/tikv5
    ports:
      - 2380:2379
    command:
      - /pd-server
      - --name=pd1
      - --client-urls=http://0.0.0.0:2379
      - --peer-urls=http://0.0.0.0:2380
      - --advertise-client-urls=http://pd1:2379
      - --advertise-peer-urls=http://pd1:2380
      - --initial-cluster=pd0=http://pd0:2380,pd1=http://pd1:2380,pd2=http://pd2:2380
    restart: on-failure
  
  pd2:
    image: marketplace.gcr.io/google/tikv5
    volumes:
      - data:/data
    ports:
      - 2381:2379
    command:
      - /pd-server
      - --name=pd2
      - --client-urls=http://0.0.0.0:2379
      - --peer-urls=http://0.0.0.0:2380
      - --advertise-client-urls=http://pd2:2379
      - --advertise-peer-urls=http://pd2:2380
      - --initial-cluster=pd0=http://pd0:2380,pd1=http://pd1:2380,pd2=http://pd2:2380
      - --data-dir=/data/pd2
    restart: on-failure
  

  tikv0:
    image: marketplace.gcr.io/google/tikv5
    ports:
      - 20160:20160
    command:
      - /tikv-server
      - --addr=0.0.0.0:20160
      - --advertise-addr=tikv0:20160
      - --pd=pd0:2379,pd1:2379,pd2:2379
    depends_on:
      - pd0
      - pd1
      - pd2
    restart: on-failure

  tikv1:
    image: marketplace.gcr.io/google/tikv5
    ports:
      - 20161:20160
    command:
      - /tikv-server
      - --addr=0.0.0.0:20160
      - --advertise-addr=tikv1:20160
      - --pd=pd0:2379,pd1:2379,pd2:2379
    depends_on:
      - pd0
      - pd1
      - pd2
    restart: on-failure

  tikv2:
    image: marketplace.gcr.io/google/tikv5
    ports:
      - 20162:20160
    command:
      - /tikv-server
      - --addr=0.0.0.0:20160
      - --advertise-addr=tikv2:20160
      - --pd=pd0:2379,pd1:2379,pd2:2379
    depends_on:
      - pd0
      - pd1
      - pd2
    restart: on-failure
```

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

```yaml
---
version: '3'

services:
  pd0:
    image: marketplace.gcr.io/google/tikv5
    volumes:
      - data:/data
    ports:
      - 2379:2379
    command:
      - /pd-server
      - --name=pd0
      - --client-urls=http://0.0.0.0:2379
      - --peer-urls=http://0.0.0.0:2380
      - --advertise-client-urls=http://pd0:2379
      - --advertise-peer-urls=http://pd0:2380
      - --initial-cluster=pd0=http://pd0:2380,pd1=http://pd1:2380,pd2=http://pd2:2380
      - --data-dir=/data/pd0
    restart: on-failure

  pd1:
    image: marketplace.gcr.io/google/tikv5
    volumes:
      - data:/data
    ports:
      - 2380:2379
    command:
      - /pd-server
      - --name=pd1
      - --client-urls=http://0.0.0.0:2379
      - --peer-urls=http://0.0.0.0:2380
      - --advertise-client-urls=http://pd1:2379
      - --advertise-peer-urls=http://pd1:2380
      - --initial-cluster=pd0=http://pd0:2380,pd1=http://pd1:2380,pd2=http://pd2:2380
      - --data-dir=/data/pd1
    restart: on-failure
  
  pd2:
    image: marketplace.gcr.io/google/tikv5
    volumes:
      - data:/data
    ports:
      - 2381:2379
    command:
      - /pd-server
      - --name=pd2
      - --client-urls=http://0.0.0.0:2379
      - --peer-urls=http://0.0.0.0:2380
      - --advertise-client-urls=http://pd2:2379
      - --advertise-peer-urls=http://pd2:2380
      - --initial-cluster=pd0=http://pd0:2380,pd1=http://pd1:2380,pd2=http://pd2:2380
      - --data-dir=/data/pd2
    restart: on-failure
  

  tikv0:
    image: marketplace.gcr.io/google/tikv5
    volumes:
      - data:/data
    ports:
      - 20160:20160
    command:
      - /tikv-server
      - --addr=0.0.0.0:20160
      - --advertise-addr=tikv0:20160
      - --data-dir=/data/tikv0
      - --pd=pd0:2379,pd1:2379,pd2:2379
    depends_on:
      - pd0
      - pd1
      - pd2
    restart: on-failure

  tikv1:
    image: marketplace.gcr.io/google/tikv5
    volumes:
      - data:/data
    ports:
      - 20161:20160
    command:
      - /tikv-server
      - --addr=0.0.0.0:20160
      - --advertise-addr=tikv1:20160
      - --data-dir=/data/tikv1
      - --pd=pd0:2379,pd1:2379,pd2:2379
    depends_on:
      - pd0
      - pd1
      - pd2
    restart: on-failure

  tikv2:
    image: marketplace.gcr.io/google/tikv5
    volumes:
      - data:/data
    ports:
      - 20162:20160
    command:
      - /tikv-server
      - --addr=0.0.0.0:20160
      - --advertise-addr=tikv2:20160
      - --data-dir=/data/tikv2
      - --pd=pd0:2379,pd1:2379,pd2:2379
    depends_on:
      - pd0
      - pd1
      - pd2
    restart: on-failure

volumes:
  data:
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port**  | **Description**  |
| :-------- | :--------------- |
| TCP 2379  | PD client port   |
| TCP 2380  | PD peer port     |
| TCP 20160 | Tikv client port |
| TCp 20180 | Tikv status port |

## <a name="references-environment-variables"></a>Environment Variables

Tikv doesn't support any ENVs, instead you should use command line parameters. 
You can see full list of acceptable parameters on the official [Tikv docs](https://tikv.org/docs/5.1/deploy/configure/tikv-command-line/). 

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path**        | **Description**                                                          |
| :-------------- | :----------------------------------------------------------------------- |
| /tmp/tikv/store | Default data dir, can be changed by --data-dir                           |
| ""              | Log path can be set by --log-file. Otherwise, logs are written to stderr |


