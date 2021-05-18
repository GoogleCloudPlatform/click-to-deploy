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
# <a name="table-of-contents"></a>Table of Contents

tbd

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/launcher/docs/launcher-container)
for additional information about setting up your Docker environment.

### <a name="start-a-MediaWiki-instance-docker"></a>Start a MediaWiki instance

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  mysql:
    container_name: some-mysql
    image: marketplace.gcr.io/google/mysql8
    environment:
      - MYSQL_ROOT_PASSWORD=dbpass1
      - MYSQL_PASSWORD=dbpass1
      - MYSQL_USER=mediawiki
      - MYSQL_DATABASE=MediaWiki
   # ports:
    #  - '127.0.0.1:3306:3306'
   # expose:
    #  - '3306
  mediawiki:
    container_name: some-mediawiki
    image: marketplace.gcr.io/google/mediawiki1-php7-apache
    ports:
      - '8080:80'
    environment:
      - MEDIAWIKI_DB_HOST=localhost
      - MEDIAWIKI_DB_PORT=3306
      - MEDIAWIKI_DB_USER=root
      - MEDIAWIKI_DB_PASSWORD=dbpass1
      - MEDIAWIKI_DBNAME=MediaWiki
      - MEDIAWIKI_DBTYPE=mysql
      - MEDIAWIKI_DB_PASSWORD=dbpass2
      - MEDIAWIKI_ADMIN_USER=admin
      - MEDIAWIKI_ADMIN_PASSWORD=adminpass
    depends_on:
      - mysql
```
Or you can use `docker run` directly:
```
docker run --name some-mediawiki -p 8080:80 -d marketplace.gcr.io/google/mediawiki1-php7-apache
```
