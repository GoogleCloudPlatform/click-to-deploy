mediawiki-docker
============

Dockerfile source for MediaWiki [docker](https://docker.io) image.

# Upstream

This source repo was originally copied from:
https://github.com/wikimedia/mediawiki-docker

# Disclaimer

This is not an official Google product.

# About
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
## Table of Contents

 * [Using Docker](#using-docker)
  * [Run a  server](#start-a-MediaWiki-instance-docker)
    * [Runnung Drupal with MariaDB Datadase service](#Runnung-Drupal-with-MariaDB-Datadase-service)
  * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
  * [Variables](#Variables)


# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/launcher/docs/launcher-container)
for additional information about setting up your Docker environment.

### <a name="start-a-MediaWiki-instance-docker"></a>Run a server
### <a name="Runnung-Drupal-with-MariaDB-Datadase-service"></a> Runnung-Drupal-with-MariaDB-Datadase-service)

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
```
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
MariaDB

```
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
# After initial setup, download LocalSettings.php to the same directory as
      # this yaml and uncomment the following line and use compose to restart
      # the mediawiki service
      # - ./LocalSettings.php:/var/www/html/LocalSettings.php
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
#    volumes:
 #     - /my/own/datadir:/var/lib/mysql
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

```
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

### <a name="Variables"></a>Variables

 | **Variable** | **Description** |
|:-------------|:----------------|
|MEDIAWIKI_DB_HOST | Hostname for MariaDB server|
|MEDIAWIKI_DB_PORT | Port used by MariaDB server|
|MEDIAWIKI_DB_USER | Database user that Drupal will use to connect with the database|
|MEDIAWIKI_DB_NAME | Database name that Drupal will use to connect with the database|
|MEDIAWIKI_ADMIN_USER| Admin user for MediaWiki|
|MEDIAWIKI_ADMIN_PASSWORD|Admin password for MediaWiki|
|ALLOW_EMPTY_PASSWORD | It can be used to allow blank passwords|
|MYSQL_USER | Database user|
|MYSQL_DATABASE | Database name|
|MYSQL_ALLOW_EMPTY_ROOT_PASSWORD|option for empty password| 
|MYSQL_HOST|Database host name|
|MYSQL_PASSWORD|Database password|
|MYSQL_ROOT_PASSWORD| Database root password|
 
