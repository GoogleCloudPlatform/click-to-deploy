hydra-docker
============

Dockerfile source for Ory Hydra [docker](https://docker.io) image.

# Upstream

This source repo was originally copied from: https://github.com/ory/hydra

# Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Ory Hydra.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/hydra).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/hydra
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/hydra/1/debian11/1.11/).

## Running Ory Hydra

This section describes how to spin up a Ory Hydra service using this image.

### Runnung Hydra with PostgreSQL Datadase service

First, let's create a network for our Hydra setup.

```shell
docker network create hydra
```

Hydra requires a separate PostgreSQL 9.6+ (or MySQL 5.7+ or SQLite) service which needs to be run in another container.

```shell
docker run \
  --network hydraguide \
  --name ory-hydra-example--postgres \
  -e POSTGRES_USER=hydra \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=hydra \
  -d marketplace.gcr.io/google/postgresql:13.4
```

When installing a new version of Hydra, or upgrading an existing installation we have to run SQL migrations.

```shell
docker run -it --rm \
  --network hydraguide \
  oryd/hydra:v1.10.6 \
  migrate sql --yes postgres://hydra:secret@ory-hydra-example--postgres:5432/hydra?sslmode=disable
```

Finally, we can run the Hydra server.

```shell
docker run -d \
  --name some-hydra \
  --network hydra \
  -p 5444:4444 \
  -p 5445:4445 \
  -e SECRETS_SYSTEM=3AD1LUmKa9ZMWFHeQ8uLdno8rX7haoog \
  -e DSN=postgres://hydra:secret@ory-hydra-example--postgres:5432/hydra?sslmode=disable \
  -e URLS_SELF_ISSUER=https://localhost:5444/ \
  -e URLS_CONSENT=http://localhost:9020/consent \
  -e URLS_LOGIN=http://localhost:9020/login \
  oryd/hydra:v1.10.6 serve all
```

## References

### Ports

ORY Hydra serves APIs via two ports:

| **Port** | **Description** |
|:---------|:----------------|
| TCP 4444 | Public port.         |
| TCP 4445 | Administrative port. |