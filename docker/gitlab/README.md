gitlab-docker
============

Dockerfile source for GitLab [docker](https://docker.io) image.

# Upstream
This source repo is based on: https://gitlab.com/gitlab-org/omnibus-gitlab/-/tree/master/docker.

# Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Drupal

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/gitlab).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/gitlab:13.12
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/gitlab/13/debian10/13.12).
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

### <a name="Runnung-Gitlab-with-PostgreSQL-and-Redis-services)"></a>Running Gitlab with PostgreSQL and Redis services] 

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  gitlab:
    container_name: gitlab
    image: marketplace.gcr.io/google/gitlab:13.12 
    ports:
      - 8080:8080
      - 8022:22
    environment:
      - |
        GITLAB_OMNIBUS_CONFIG=
        external_url ENV['EXTERNAL_URL'];
        root_pass = ENV['GITLAB_ROOT_PASSWORD'];
        gitlab_rails['initial_root_password'] = root_pass unless root_pass.to_s == '';
        unicorn['worker_processes'] = 1;
        manage_accounts['enable'] = true;
        nginx['redirect_http_to_https'] = false;
        nginx['listen_port'] = 8080;
        nginx['listen_https'] = false;
        letsencrypt['enable'] = false;
      - GITLAB_ROOT_PASSWORD=some-password
      - EXTERNAL_URL=http://localhost:8080
```

### <a name="Runnung-Gitlab-with-PostgreSQL-and-Redis-services)"></a>Running Gitlab with PostgreSQL and Redis services] 


