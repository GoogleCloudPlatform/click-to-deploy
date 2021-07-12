# neo4j-docker

Neo4j Community Edition is an open source graph database management system written in Java.
It provides a web dashboard for managing data and users.
Service is accessible through HTTP REST API or binary bolt protocol.

The Community Edition is perfect for learning or small projects, not production scale.
Solution does not support clustering, sharding data or advanced indexes.

For more information on Neo4j versions, see the [official website](https://neo4j.com/subscriptions/#editions).

## Upstream

This source repo was originally copied from: https://github.com/neo4j/docker-neo4j

# Disclaimer

This is not an official Google product.

## About
This image contains an installation of Neo4j

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/neo4j4).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/neo4j4
```
## Table of Contents

 [Using Docker](#using-docker)
  * [Run a server](#run-a-activemq-server-docker)
    * [Running Neo4j Service](#Running-Neo4j-service)
  * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
  * [Variables, paths and ports](#Variables)

# Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

### <a name="Running-Neo4j-service"></a>Running Neo4j Service

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

 ```yaml
version: '2'
services:
  neo4j:
    container_name: some-neo4j
    image: marketplace.gcr.io/google/neo4j4
    hostname: neo4j
    ports:
      - "7474:7474"
      - "7687:7687"
    environment:
      - NEO4J_AUTH=some-user/some-password
      - NEO4J_dbms_logs_debug_level=DEBUG 
 ```
Remote interface available at http://0.0.0.0:7474/ 
 
Or you can use `docker run` directly:
 
```shell
docker run  --name 'some-neo4j' -it --rm \
      -p 7474:7474 \
      -p 7687:7687 \
      -e NEO4J_AUTH="neo4j/some-password" \
      -e NEO4J_dbms_logs_debug_level=DEBUG \
marketplace.gcr.io/google/neo4j4
```
    
### <a name="Use-a-persistent-data-volume-docker"></a>Use a persistent data volume
   
Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.
   
   ```yaml
version: '2'
services:
  neo4j:
    container_name: some-neo4j
    image: marketplace.gcr.io/google/neo4j4
    hostname: neo4j
    ports:
      - "7474:7474"
      - "7687:7687"
    volumes:
      - ./conf:/conf
      - ./data:/data
      - ./import:/import
      - ./logs:/logs
      - ./plugins:/plugins
    environment:
      NEO4J_AUTH: neo4j/some-password
      NEO4J_dbms_logs_debug_level: DEBUG
 ```
      
Remote interface available at http://0.0.0.0:7474/ 
 
Or you can use `docker run` directly:
  
```shell
docker run --name 'some-neo4j' -it --rm \
      -p 7474:7474 \
      -p 7687:7687 \
      -e NEO4J_AUTH="neo4j/some-password" \
      -e NEO4J_dbms_logs_debug_level=DEBUG \
      -v /conf:/conf \
      -v /data:/data \
      -v /import:/import \
      -v /logs:/logs \
      -v /plugins:/plugins \
marketplace.gcr.io/google/neo4j4
```
 
### <a name="Variables"><Variables, paths and ports


These are the environment variables understood by the container image.
 
| **Variable** | **Description** |
|:-------------|:----------------|
|NEO4J_AUTH| neo4j credentials|
|NEO4J_dbms_logs_debug_level| log level|
 
 
These are the filesystem ports used by the container image.
 
| **Port** | **Description** |
|:---------|:----------------|
|7474|HTTP listen prot |
|7687|Bolt connector port |

These are the filesystem paths used by the container image.

| **Path** | **Description** |
|:---------|:----------------|
|/conf| Neo4j configs |
|/data| Neo4j data files |
|/import| DB related folder |
|/logs| Path for logs |
|/plugins| Path for plugins |
 
