Dirigible
============

Eclipse Dirigible is a High-Productivity Application Platform as a Service (hpaPaaS). It provides an application server consisting of pre-selected execution engines and built-in development tools as WebIDE. It is suitable for rapid development of business applications by also leveraging the Low Code / No Code techniques.

For more information, see the Harbor [GitHub](https://github.com/eclipse/dirigible) and [official documentation](https://www.dirigible.io/help/).

# Disclaimer
This is not an official Google product.

# <a name="about"></a>About
This image contains an installation of Dirigible

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/dirigible6).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/dirigible6
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/dirigible/6/debian11/6.3).
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Create volume](#create-mounted-volume)
  * [Start an dirigible instance](#start-a-dirigible-instance-docker)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="create-mounted-volume"></a> Create mounted volume

Create directory to keep your files in Dirigible.

```shell
mkdir data/
```

## <a name="start-a-dirigible-instance-docker"></a> Start an Dirigible instance

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  dirigible:
    container_name: dirigible
    image: marketplace.gcr.io/google/dirigible6:6.3
    environment:
       - DIRIGIBLE_BRANDING_NAME="My Web IDE"
       - DIRIGIBLE_BRANDING_BRAND="WebIDE"
       - DIRIGIBLE_BRANDING_BRAND_URL="https://www.eclipse.org"
       - DIRIGIBLE_THEME_DEFAULT="fiori"
    ports:
      - "8080:8080"
    volumes:
      - ./data/:/usr/local/tomcat/target
```

Or you can use `docker run` directly:

```shell
docker run --name='dirigible' -it --rm \
    -e DIRIGIBLE_BRANDING_NAME="My Web IDE" \
    -e DIRIGIBLE_BRANDING_BRAND="WebIDE" \
    -e DIRIGIBLE_BRANDING_BRAND_URL="https://www.eclipse.org" \
    -e DIRIGIBLE_THEME_DEFAULT="fiori" \
    -p 8080:8080 \
    -v $PWD/data/:/usr/local/tomcat/target \
    marketplace.gcr.io/google/dirigible6:6.3
```

Default username and password is `dirigible`

Dirigible is available at `http://127.0.0.1:8080`

# <a name="references"></a> References

## <a name="references-ports"></a>Available Ports

These are the available ports which can be set for the image.

| **Port** | **Description** |
|:-------------|:----------------|
|8080 | HTTP |
|8081 | GRAALVM_DEBUGGER_PORT |
|8000 | Java Debugging Options |

## <a name="references-environment-variables"></a>Environment Variables

These are the available environment variables understood by the container image.

| **Variable** | **Description** |
|:-------------|:----------------|
|DIRIGIBLE_BRANDING_NAME| Set branding name |
|DIRIGIBLE_BRANDING_BRAND| Set brand |
|DIRIGIBLE_BRANDING_BRAND_URL| Set brand url |
|DIRIGIBLE_THEME_DEFAULT| Default theme |
|JPDA_ADDRESS| Java debug address and port |
|JPDA_TRANSPORT| JPDA Transport communication |

## <a name="references-volumes"></a>Volumes

The paths used by Dirigible.

| **Path** | **Description** |
|:---------|:----------------|
|/usr/local/tomcat/target| All important files are keep in this path. |