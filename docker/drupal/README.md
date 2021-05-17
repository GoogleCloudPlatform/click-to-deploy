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
[Official Image Marketplace Page](to-do).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/drupal
```
## Table of Contents

 [Using Docker](#using-docker)
  * [Run a  server](#run-a-activemq-server-docker)
    * [Runnung Drupal with Postgres Datadase service](#Runnung Drupal with Postgres Datadase service)
    * [Runnung Drupal with MariaDB Datadase service](#Runnung Drupal with MariaDB Datadase service)
  * [Configurations](#configurations-docker)
    * [Authentication and authorization](#authentication-and-authorization-docker)
* [References](#references)
  * [Ports](#references-ports)

# Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## Runnung Drupal with Postgres Datadase service 

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  drupal:
    image: drupal:latest
    ports:
      - 8080:80
    volumes:
      - /var/www/html/modules
      - /var/www/html/profiles
      - /var/www/html/themes
      - /var/www/html/sites
    restart: always

  postgres:
    image: postgres:latest
    environment:
      POSTGRES_PASSWORD: some-password
    restart: always
 
```
 Or you can use `docker run` directly:

```
 docker run --name some-drupal -p 8080:80 -d drupal
 
```
 Then, access it via http://localhost:8080 or http://host-ip:8080 in a browser.
 
## Runnung Drupal with MirandaDB Datadase service 
 
 Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

 ```yaml
 version: '2'
services:
  mariadb:
    image: mariadb:latest
    environment:
      - ALLOW_EMPTY_PASSWORD=yes
      - MARIADB_USER=bn_drupal
      - MARIADB_DATABASE=bitnami_drupal
    volumes:
      - 'mariadb_data:/bitnami/mariadb'
  drupal:
    image: drupal:latest
    ports:
      - '80:8080'
      - '443:8443'
    environment:
      - DRUPAL_DATABASE_HOST=mariadb
      - DRUPAL_DATABASE_PORT_NUMBER=3306
      - DRUPAL_DATABASE_USER=bn_drupal
      - DRUPAL_DATABASE_NAME=bitnami_drupal
      - ALLOW_EMPTY_PASSWORD=yes
    volumes:
      - 'drupal_data:/bitnami/drupal'
    depends_on:
      - mariadb
```
 | **Variable** | **Description** |
|:-------------|:----------------|
|DRUPAL_DATABASE_HOST | Hostname for MariaDB server|
|DRUPAL_DATABASE_PORT_NUMBER | Port used by MariaDB server|
|DRUPAL_DATABASE_USE | Database user that Drupal will use to connect with the database|
|DRUPAL_DATABASE_NAME | Database name that Drupal will use to connect with the database|
|ALLOW_EMPTY_PASSWORD | It can be used to allow blank passwords|
|MARIADB_USER | Database user|
|MARIADB_DATABASE | Database name|
 
 

