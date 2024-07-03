nuclio-docker
============

Nuclio is a serverless platform which provide run code as the service.

# Upstream
Build instruction for docker containers partially copied from:
https://github.com/nuclio/nuclio

# Disclaimer
This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Nuclio.

For more information, see the [Official Nuclio Dashboard Marketplace Page](https://console.cloud.google.com/marketplace/product/google/nuclio-dashboard1).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/nuclio-dashboard1
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/nuclio/nuclio_builder/)
=======


# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Nuclio](#running-nuclio-docker)
    * [Running Nuclio Dashboard](#Running-Nuclio-Dashboard)
    * [Use a persistent data volume docker (Enterprise version only)](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="runnig-nuclio-docker"></a>Running Nuclio

This section describes how to spin up a Nuclio service using this image.

### <a name="Runnung-Nuclio-Dashboard"></a>Running Nuclio Dashboard

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  nuclio-dashboard:
    container_name: nuclio-dashboard
    restart: always
    image: marketplace.gcr.io/google/nuclio-dashboard1
    ports:
      - 8070:8070
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

Or you can use `docker run` directly:

```shell
docker run -d \
    -p 8070:8070 \
    --name nuclio-dashboard \
    -v /var/run/docker.sock:/var/run/docker.sock \
    marketplace.gcr.io/google/nuclio-dashboard1
```

Then, access it via [http://localhost:8070](http://localhost:8070) or `http://host-ip:8070` in a browser.

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume (Enterprise version only)

The first time you run Nuclio, it creates a container named `nuclio-local-storage-reader`, no further action is required.

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container images.

| **Port** | **Description**   |
| :------- | :---------------- |
| TCP 8070 | Nuclio Dashboard. |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container images.

| **Variable**                  | **Description**                                                    |
| :---------------------------- | :----------------------------------------------------------------- |
| NUCLIO_DASHBOARD_REGISTRY_URL | Use target docker registry.                                        |
| NUCLIO_CONTAINER_BUILDER_KIND | Container builder, can be `docker` or `kaniko`, docker by default. |

You can see full list of supported ENVs in the [Official Helm chart](https://github.com/nuclio/nuclio/blob/master/hack/k8s/helm/nuclio/templates/deployment/dashboard.yaml).

## <a name="references-volumes"></a>Volumes

Nuclio requires a Docker socket `/var/run/docker.sock` to build and run containers. 

