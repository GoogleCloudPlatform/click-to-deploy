drupal-docker
============

Dockerfile source for Drupal [docker](https://docker.io) image

# Upstream

This source repo was originally copied from:
https://github.com/docker-library/drupal


# Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Drupal

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/drupal9-php7-apache).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/drupal9-php7-apache
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/drupal/9/php7/debian9/9.2/apache).
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Drupal](#running-drupal-docker)
    * [Running Drupal with MariaDB Datadase service](#Runnung-Drupal-with-MariaDB-Datadase-service)
    * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-drupal-docker"></a>Running Drupal

This section describes how to spin up a Drupal service using this image.

### <a name="Runnung-Drupal-with-MariaDB-Datadase-service"></a>Runnung Drupal with MariaDB Datadase service 

Drupal requires a separate MySQL service which can be run in another container.
 
Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
 mariadb:
  container_name: some-mariadb
  image: marketplace.gcr.io/google/mariadb10
  environment:
    - MYSQL_HOST=mariadb
    - MYSQL_USER=drupal
    - MYSQL_DATABASE=drupal
    - MYSQL_PASSWORD=some-password
    - MYSQL_ROOT_PASSWORD=some-passowrd
 drupal:
  container_name: some-drupal
  image: marketplace.gcr.io/google/drupal9-php7-apache
  ports:
    - 8080:80
    - 8443:443
  environment:
    - MYSQL_PORT_3306_TCP=3306
    - DRUPAL_DB_HOST=mariadb
    - DRUPAL_DB_PASSWORD=some-password
  depends_on:
    - mariadb
```

Or you can use `docker run` directly:

```shell
 docker network create drupal
```

Drupal:

```shell
docker run -d --name 'some-drupal' -it --rm \
    -p 8080:80 \
    -p 8443:443 \
    -e MYSQL_PORT_3306_TCP=3306 \
    -e DRUPAL_DB_HOST=some-mariadb \
    -e DRUPAL_DB_USER=drupal \
    -e DRUPAL_USER=admin\
    -e DRUPAL_DB_PASSWORD=some-password \
    --network drupal \
    marketplace.gcr.io/google/drupal9-php7-apache
```

MariaDB:

```shell
docker run -d --name 'some-mariadb' -it --rm \
    -p 127.0.0.1:3306:3306 \
    -e MYSQL_USER=drupal \
    -e MYSQL_DATABASE=drupal \
    -e MYSQL_PASSWORD=some-password \
    -e MYSQL_ROOT_PASSWORD=some-passowrd \
    --network drupal \
    marketplace.gcr.io/google/mariadb10
```
Then, access it via `http://localhost:8080` or `http://host-ip:8080` in a browser.
 
 ### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

```yaml
version: '2'
services:
 mariadb:
  container_name: some-mariadb
  image: marketplace.gcr.io/google/mariadb10
  environment:
    - MYSQL_HOST=mariadb
    - MYSQL_USER=drupal
    - MYSQL_DATABASE=drupal
    - MYSQL_PASSWORD=some-password
    - MYSQL_ROOT_PASSWORD=some-password
  command: --default-authentication-plugin=mysql_native_password
  volumes:
    - /var/lib/mysql
 drupal:
  container_name: some-drupal
  image: marketplace.gcr.io/google/drupal9-php7-apache
  ports:
    - 8080:80
    - 8443:443
  environment: 
    - MYSQL_PORT_3306_TCP=3306
    - DRUPAL_DB_HOST=mariadb
    - DRUPAL_DB_PASSWORD=some-password
    - DRUPAL_NO_CHECK_VOLUME=yes
  volumes:
    - /var/www/html/modules
    - /var/www/html/profiles
    - /var/www/html/themes
    - /var/www/html/sites
  depends_on:
    - mariadb
```

Or you can use `docker run` directly:

```shell
 docker network create drupal
```

```shell
docker run -d --name 'some-drupal' -p 8080:80 -p 8443:443 \
    -e MYSQL_PORT_3306_TCP=3306 \
    -e DRUPAL_DB_HOST=mariadb \
    -e DRUPAL_DB_PASSWORD=some-password \
    --network drupal \
    -v /var/www/html/modules \
    -v /var/www/html/profiles \ 
    -v /var/www/html/themes \
    -v /var/www/html/sites \
    marketplace.gcr.io/google/drupal9-php7-apache
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
|:---------|:----------------|
| TCP 80 | Standard HTTP port. |
| TCP 443 | Standard HTTPS port. |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

 | **Variable** | **Description** |
|:-------------|:----------------|
|DRUPAL_DB_HOST | Hostname for MariaDB server. |
|DRUPAL_DB_PORT | Port used by MariaDB server. |
|DRUPAL_DB_USER | Database user that Drupal will use to connect with the database. |
|DRUPAL_DB_PASSWORD| Database password. |
|DRUPAL_PASSWORD|Admin password. |
|DRUPAL_USER|Admin user. |
|DRUPAL_DB_NAME | Database name that Drupal will use to connect with the database. |
|ALLOW_EMPTY_PASSWORD | It can be used to allow blank passwords. |
|MYSQL_USER | Database user. |
|MYSQL_DATABASE | Database name. |
|MYSQL_ALLOW_EMPTY_ROOT_PASSWORD|option for empty password. | 
|MYSQL_HOST|Database host name. |
|MYSQL_PASSWORD|Database password. |
|MYSQL_ROOT_PASSWORD| Database root password .|
 
## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description** |
|:---------|:----------------|
|/var/www/html| All Drupal files are installed here containing user uploaded data, themes, profiles and modules. |
