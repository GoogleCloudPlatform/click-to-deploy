# spark-docker

Container solution for Apache Spark.
Learn more about Apache Spark in [official documentation](https://spark.apache.org/).

## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Apache Spark.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/spark3).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/spark3
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/spark/3/debian11/3.3/)
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Spark](#running-spark)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)


# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-spark-docker"></a>Running Spark

This section describes how to spin up an Spark service using this image.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
---
services:
  spark-master:
    image: marketplace.gcr.io/google/spark3:3.3
    ports:
      - "127.0.0.1:9090:8080"
      - "127.0.0.1:7077:7077"
    environment:
      SPARK_LOCAL_IP: spark-master
      SPARK_WORKLOAD: master
  spark-worker-a:
    image: marketplace.gcr.io/google/spark3:3.3
    ports:
      - "127.0.0.1:9091:8080"
      - "127.0.0.1:7000:7000"
    environment:
      SPARK_MASTER: spark://spark-master:7077
      SPARK_WORKLOAD: worker
      SPARK_LOCAL_IP: spark-worker-a
    depends_on:
      - spark-master
  spark-worker-b:
    image: marketplace.gcr.io/google/spark3:3.3
    ports:
      - "127.0.0.1:9092:8080"
      - "127.0.0.1:7001:7000"
    environment:
      SPARK_MASTER: spark://spark-master:7077
      SPARK_WORKLOAD: worker
      SPARK_LOCAL_IP: spark-worker-b
    depends_on:
      - spark-master
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port**  | **Description**    |
| :-------  | :----------------- |
| TCP 7077  | Spark TCP          |
| TCP 8080  | Spark UI           |
| TCP 18080 | History Server UI  |

## <a name="references-environment-variables"></a>Enviment Variables

These are the environment variables understood by the container image.
| **Variable**          | **Description**                                                       |
|-----------------------|-----------------------------------------------------------------------|
| SPARK_WORKLOAD        | master or worker                                                      |
| SPARK_LOCAL_IP        | Eg. `hostname`. Defines ip which server will listen to.               |
| SPARK_MASTER          | Eg. spark://hostname:7077. Spark master address                       |
| ENABLE_PROMETHEUS     | false (default) /true. Whether prometheus metrics are enabled or not. |
| ENABLE_HISTORY        | false (default) /true. Whether history server is enabled or not.      |
