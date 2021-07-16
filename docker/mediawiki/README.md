mediawiki-docker
============

Dockerfile source for MediaWiki [docker](https://docker.io) image.

# Upstream

This source repo was originally copied from:
https://github.com/wikimedia/mediawiki-docker

# Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of MediaWiki

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/mediawiki1-php7-apache).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```

### Pull command

```shell
docker -- pull marketplace.gcr.io/google/mediawiki1-php7-apache
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/mediawiki/1/debian9/1.36).
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Run a  server](#start-a-mediaWiki-instance-docker)
    * [Running Mediawiki with MySQL Service](#runnung-mediawiki-with-mysql-db-service)
    * [Use a persistent data volume docker](#use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)


# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/launcher/docs/launcher-container)
for additional information about setting up your Docker environment.

## <a name="start-a-mediaWiki-instance-docker"></a>Run a server

This section describes how to spin up a Mediawiki service using this image.

### <a name="runnung-mediawiki-with-mysql-db-service"></a>Running Mediawiki with MySQL DB Service

Mediawiki requires a separate MySQL service which can be run in another container.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  mariadb:
    container_name: mariadb
    image: marketplace.gcr.io/google/mariadb10
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_PASSWORD=dbpassword
      - MYSQL_USER=mediawiki
      - MYSQL_DATABASE=MediaWiki
      - MYSQL_HOST=mariandb
  mediawiki:
    container_name: some-mediawiki
    image: marketplace.gcr.io/google/mediawiki1-php7-apache
    ports:
      - '8080:80'
    environment:
      - MEDIAWIKI_DB_HOST=mariadb
      - MEDIAWIKI_DB_PORT=3306
      - MEDIAWIKI_DB_USER=mediawiki
      - MEDIAWIKI_DB_PASSWORD=dbpassword
      - MEDIAWIKI_DBNAME=MediaWiki
      - MEDIAWIKI_DBTYPE=mysql
      - MEDIAWIKI_ADMIN_USER=admin
      - MEDIAWIKI_ADMIN_PASSWORD=adminpassword
    depends_on:
      - mariadb
```
Or you can use `docker run` directly:

Mediawiki:

```shell
docker run --name some-mediawiki -p 8080:80 -d \
      -e MEDIAWIKI_DB_HOST=mariadb \
      -e MEDIAWIKI_DB_PORT=3306 \
      -e MEDIAWIKI_DB_USER=mediawiki \
      -e MEDIAWIKI_DB_PASSWORD=dbpassword \
      -e MEDIAWIKI_DBNAME=MediaWiki \
      -e MEDIAWIKI_DBTYPE=mysql \
      -e MEDIAWIKI_ADMIN_USER=admin \
      -e MEDIAWIKI_ADMIN_PASSWORD=adminpassword \
      marketplace.gcr.io/google/mediawiki1-php7-apache
```

MariaDB:

```shell
docker run --name some-mariadb -d -it \
      -e MYSQL_ROOT_PASSWORD=rootpassword \
      -e MYSQL_PASSWORD=dbpassword \ 
      -e MYSQL_USER=mediawiki \
      -e MYSQL_DATABASE=MediaWiki \
      -e MYSQL_HOST=mariandb \
      marketplace.gcr.io/google/mariadb10

```


### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

```
After initial setup, download LocalSettings.php to the same directory as this yaml 
and uncomment the following line and use compose to restart 
the mediawiki service - ./LocalSettings.php:/var/www/html/LocalSettings.php
```

```yaml
version: '2'
services:
  mariadb:
    container_name: mariadb
    image: marketplace.gcr.io/google/mariadb10
    environment:
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_PASSWORD=dbpassword
      - MYSQL_USER=mediawiki
      - MYSQL_DATABASE=MediaWiki
      - MYSQL_HOST=mariandb
    volumes:
      - /my/own/datadir:/var/lib/mysql
    command: ["--default-authentication-plugin=mysql_native_password"]
  mediawiki:
    container_name: some-mediawiki
    image: marketplace.gcr.io/google/mediawiki1-php7-apache
    ports:
      - '8080:80'
    environment:
      - MEDIAWIKI_DB_HOST=mariadb
      - MEDIAWIKI_DB_PORT=3306
      - MEDIAWIKI_DB_USER=mediawiki
      - MEDIAWIKI_DB_PASSWORD=dbpassword
      - MEDIAWIKI_DB_NAME=MediaWiki
      - MEDIAWIKI_DBTYPE=mysql
      - MEDIAWIKI_ADMIN_USER=admin
      - MEDIAWIKI_ADMIN_PASSWORD=adminpassword
      volumes:
      - /var/www/html/images
      - /LocalSettings.php:/var/www/html/LocalSettings.php
    depends_on:
      - mariadb
```
Or you can use `docker run` directly:

```shell
docker run --name some-mediawiki -p 8080:80 -d \
      -e MEDIAWIKI_DB_HOST=mariadb \
      -e MEDIAWIKI_DB_PORT=3306 \
      -e MEDIAWIKI_DB_USER=mediawiki \
      -e MEDIAWIKI_DB_PASSWORD=dbpassword \
      -e MEDIAWIKI_DBNAME=MediaWiki \
      -e MEDIAWIKI_DBTYPE=mysql \
      -e MEDIAWIKI_ADMIN_USER=admin \
      -e MEDIAWIKI_ADMIN_PASSWORD=adminpassword \
      -v /var/www/html/images
      -v /LocalSettings.php:/var/www/html/LocalSettings.php
      marketplace.gcr.io/google/mediawiki1-php7-apache
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
|:-------------|:----------------|
| TCP 80 | Standard HTTP port. |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable** | **Description** |
|:-------------|:----------------|
|MEDIAWIKI_DB_HOST | Hostname for MariaDB server. |
|MEDIAWIKI_DB_PORT | Port used by MariaDB server. |
|MEDIAWIKI_DB_USER | MediaWiki user will use to connect with the database. |
|MEDIAWIKI_DB_NAME | MediaWiki name will use to connect with the database. |
|MEDIAWIKI_ADMIN_USER| Admin user for MediaWiki .|
|MEDIAWIKI_ADMIN_PASSWORD|Admin password for MediaWiki. |
|ALLOW_EMPTY_PASSWORD | It can be used to allow blank passwords. |
|MYSQL_USER | Database user. |
|MYSQL_DATABASE | Database name. |
|MYSQL_ALLOW_EMPTY_ROOT_PASSWORD|option for empty password.|
|MYSQL_HOST|Database host name. |
|MYSQL_PASSWORD|Database password. |
|MYSQL_ROOT_PASSWORD| Database root password. |
 
## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description** |
|:---------|:----------------|
|/var/www/html| All MideiaWiki filesare installed here. |
