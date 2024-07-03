gitlab-docker
============

Dockerfile source for GitLab [docker](https://docker.io) image.

# Upstream
This source repo is based on: https://gitlab.com/gitlab-org/omnibus-gitlab/-/tree/master/docker.

# Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Gitlab.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/gitlab14).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/gitlab14
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/gitlab/14/debian10/14.7).
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Gitlab](#running-gitlab-docker)
    * [Running Gitlab standalone](#Running-Gitlab-standalone)
    * [Running Gitlab with PostgreSQL and Redis services](#Runnung-Gitlab-with-PostgreSQL-and-Redis-services)
    * [Use a persistent data volume docker](#Use-a-persistent-data-volume)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-gitlab-docker"></a>Running Gitlab

This section describes how to spin up a Gitlab service using this image.

### <a name="Runnung-Gitlab-standalone"></a>Running Gitlab standalone 

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  gitlab:
    container_name: gitlab
    image: marketplace.gcr.io/google/gitlab14 
    ports:
      - 8080:80
      - 8022:22
    environment:
      - |
        GITLAB_OMNIBUS_CONFIG=
        external_url ENV['EXTERNAL_URL'];
        root_pass = ENV['GITLAB_ROOT_PASSWORD'];
        gitlab_rails['initial_root_password'] = root_pass unless root_pass.to_s == '';
        manage_accounts['enable'] = true;
        nginx['redirect_http_to_https'] = false;
        nginx['listen_port'] = 80;
      - GITLAB_ROOT_PASSWORD=some-password
      - EXTERNAL_URL=http://localhost:8080
```

Or you can use `docker run` directly:

```shell
docker run -d --name 'gitlab' -it --rm \
    -p 8080:80 \
    -p 8022:22 \
    -e GITLAB_OMNIBUS_CONFIG="
    external_url 'http://localhost:8080'; \
    root_pass = 'some-password'; \
    manage_accounts['enable'] = true; \
    nginx['redirect_http_to_https'] = false; \
    nginx['listen_port'] = 80;" \
    marketplace.gcr.io/google/gitlab14
```

Then, access it via [http://localhost:8080](http://localhost:8080) or `http://host-ip:8080` in a browser.

### <a name="Runnung-Gitlab-with-PostgreSQL-and-Redis-services"></a>Running Gitlab with PostgreSQL and Redis services

Gitlab requires PostgreSQL and Redis services, which can be run in external containers.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  postgres:
    container_name: postgres
    image: marketplace.gcr.io/google/postgresql13
    environment:
      - POSTGRES_USER=gitlab
      - POSTGRES_PASSWORD=some-password
  redis:
    container_name: redis
    image: marketplace.gcr.io/google/redis6
    command: ["redis-server", "--requirepass", "some-password", "--dir", "/data"]
  gitlab:
    container_name: gitlab
    image: marketplace.gcr.io/google/gitlab14
    ports:
      - 8080:80
      - 8022:22
    environment:
      - |
        GITLAB_OMNIBUS_CONFIG=
        external_url ENV['EXTERNAL_URL'];
        root_pass = ENV['GITLAB_ROOT_PASSWORD'];
        gitlab_rails['initial_root_password'] = root_pass unless root_pass.to_s == '';
        # Postgresql settings
        postgresql['enable'] = false;
        gitlab_rails['db_host'] = "postgres";
        gitlab_rails['db_password'] = ENV['DB_PASSWORD'];
        gitlab_rails['db_username'] = ENV['DB_USER'];
        gitlab_rails['db_database'] = "gitlab";
        # Redis settings
        redis['enable'] = false;
        gitlab_rails['redis_host'] = "redis";
        gitlab_rails['redis_password'] = ENV['REDIS_PASSWORD'];
        manage_accounts['enable'] = true;
        nginx['redirect_http_to_https'] = false;
        nginx['listen_port'] = 80;
      - GITLAB_ROOT_PASSWORD=some-password
      - EXTERNAL_URL=http://localhost:8080
      - DB_USER=gitlab
      - DB_PASSWORD=some-password
      - REDIS_PASSWORD=some-password
    depends_on:
      - postgres
      - redis
```

Then, access it via [http://localhost:8080](http://localhost:8080) or `http://host-ip:8080` in a browser.

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

```yaml
version: '2'
services:
  postgres:
    container_name: postgres
    image: marketplace.gcr.io/google/postgresql13
    environment:
      - POSTGRES_USER=gitlab
      - POSTGRES_PASSWORD=some-password
    volumes:
      - /var/lib/postgresql/data
  redis:
    container_name: redis
    image: marketplace.gcr.io/google/redis6
    command: ["redis-server", "--requirepass", "some-password", "--dir", "/data"]
    volumes:
      - /data
  gitlab:
    container_name: gitlab
    image: marketplace.gcr.io/google/gitlab14
    ports:
      - 8080:80
      - 8022:22
    environment:
      - |
        GITLAB_OMNIBUS_CONFIG=
        external_url ENV['EXTERNAL_URL'];
        root_pass = ENV['GITLAB_ROOT_PASSWORD'];
        gitlab_rails['initial_root_password'] = root_pass unless root_pass.to_s == '';
        # Postgresql settings
        postgresql['enable'] = false;
        gitlab_rails['db_host'] = "postgres";
        gitlab_rails['db_password'] = ENV['DB_PASSWORD'];
        gitlab_rails['db_username'] = ENV['DB_USER'];
        gitlab_rails['db_database'] = "gitlab";
        # Redis settings
        redis['enable'] = false;
        gitlab_rails['redis_host'] = "redis";
        gitlab_rails['redis_password'] = ENV['REDIS_PASSWORD'];
        manage_accounts['enable'] = true;
        nginx['redirect_http_to_https'] = false;
        nginx['listen_port'] = 80;
      - GITLAB_ROOT_PASSWORD=some-password
      - EXTERNAL_URL=http://localhost:8080
      - DB_USER=gitlab
      - DB_PASSWORD=some-password
      - REDIS_PASSWORD=some-password
    depends_on:
      - postgres
      - redis
    volumes:
      - /var/opt/gitlab
      - /var/log/gitlab
      - /etc/gitlab
```

Then, access it via [http://localhost:8080](http://localhost:8080) or `http://host-ip:8080` in a browser.

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port**   | **Description**      |
| :--------- | :------------------- |
| TCP 22     | Standard SSH port.   |
| TCP 80     | Standard HTTP port.  |
| TCP 443    | Standard HTTPS port. |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable**          | **Description**                     |
| :-------------------- | :---------------------------------- |
| GITLAB_OMNIBUS_CONFIG | Additional parameters for gitlab.rb |

You can see full list of acceptable parameters on the official [Gitlab docs](https://docs.gitlab.com/omnibus/settings/configuration.html). 

Any additional ENVs can be added via parameters in the GITLAB_OMNIBUS_CONFIG, e.g. `gitlab_rails['db_password'] = ENV['DB_PASSWORD'];`.


## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path**        | **Description**                                               |
| :-------------- | :------------------------------------------------------------ |
| /var/opt/gitlab | Gitlab storage with repositories, artifacts, packages, etc... |
| /var/log/gitlab | Gitlab and related services logs                              |
| /etc/gitlab     | Gitlab configuration files                                    |

