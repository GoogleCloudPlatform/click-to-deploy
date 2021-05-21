drupal-docker
============

Dockerfile source for Drupal [docker](https://docker.io) image.

# Upstream

This source repo was originally copied from:
https://github.com/docker-library/drupal


# Disclaimer

This is not an official Google product.

## About
This image contains an installation of Drupal

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/drupal).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/drupal9-php7-apache
```
## Table of Contents

 [Using Docker](#using-docker)
  * [Run a  server](#run-a-activemq-server-docker)
    * [Runnung Drupal with MariaDB Datadase service](#Runnung-Drupal-with-MariaDB-Datadase-service)
  * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
  * [Variables](#Variables)

# Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

### <a name="Runnung-Drupal-with-MariaDB-Datadase-service"></a>Runnung Drupal with MariaDB Datadase service 
 
 Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

 ```yaml                                                                     
version: '2'
services:
 mariadb:
  container_name: mariadb
  image: marketplace.gcr.io/google/mariadb10
  environment:
    - MYSQL_HOST=mariadb
    - MYSQL_USER=drupal
    - MYSQL_DATABASE=drupal
    - MYSQL_PASSWORD=some-password
    - MYSQL_ROOT_PASSWORD=some-passowrd
  command: --default-authentication-plugin=mysql_native_password
 drupal:
  container_name: drupal
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
 Then, access it via http://localhost:8080 or http://host-ip:8080 in a browser.
 
Or you can use `docker run` directly:

```
docker run -d --name some-drupal -p 8080:80 -p 8443:443  \
    -e MYSQL_PORT_3306_TCP=3306 \
    -e DRUPAL_DB_HOST=mariadb \
    -e DRUPAL_DB_PASSWORD=some-password \
    marketplace.gcr.io/google/drupal9-php7-apache
```
MariaDB

```
docker run -d --name mariadb \
    -e MYSQL_HOST=mariadb \
    -e MYSQL_USER=drupal \
    -e MYSQL_DATABASE=drupal \
    -e MYSQL_PASSWORD=some-password \
    -e MYSQL_ROOT_PASSWORD=some-passowrd \
marketplace.gcr.io/google/mariadb10
```
 
 
 ### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume
 ```yaml  
 version: '2'
services:
 mariadb:
  container_name: mariadb
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
  container_name: drupal
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

```
docker run -d --name some-drupal \
    -v /path/on/host/modules:/var/www/html/modules \
    -v /path/on/host/profiles:/var/www/html/profiles \
    -v /path/on/host/sites:/var/www/html/sites \
    -v /path/on/host/themes:/var/www/html/themes \
    marketplace.gcr.io/google/drupal9-php7-apache
```

 ### <a name="Variables"></a>Variables

 | **Variable** | **Description** |
|:-------------|:----------------|
|DRUPAL_DB_HOST | Hostname for MariaDB server|
|DRUPAL_DB_PORT | Port used by MariaDB server|
|DRUPAL_DB_USER | Database user that Drupal will use to connect with the database|
|DRUPAL_DB_NAME | Database name that Drupal will use to connect with the database|
|ALLOW_EMPTY_PASSWORD | It can be used to allow blank passwords|
|MYSQL_USER | Database user|
|MYSQL_DATABASE | Database name|
|MYSQL_ALLOW_EMPTY_ROOT_PASSWORD|option for empty password| 
|MYSQL_HOST|Database host name|
|MYSQL_PASSWORD|Database password|
|MYSQL_ROOT_PASSWORD| Database root password|
 

