django-docker
============
Dockerfile source for Django [docker](https://docker.io) image.

# Disclaimer
This is not an official Google product.

# <a name="about"></a>About
This image contains an installation of Django with UWSGI

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/product/google/django4).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull **command**

```shell
docker -- pull marketplace.gcr.io/google/django4
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/django/4/debian11/4.1).
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Docker](#using-docker)
  * [Running Django](#running-django-docker)
    * [Start a Django instance](#start-a-django-instance-docker)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-django-docker"></a>Running Django Docker

### <a name="start-a-django-instance-docker"></a> Start a Django docker instance

Create the NGINX configuration file:

```shell
cat > nginx.conf <<EOF
    # configuration of the server
    server {
        # the port your site will be served on
        listen      8081;

        location /stub_status {
          stub_status on;
          access_log off;
          allow 127.0.0.1;
          deny all;
        }
        # the domain name it will serve for
        server_name localhost; # substitute your machine's IP address or FQDN
        charset     utf-8;
        # max upload size
        client_max_body_size 75M;   # adjust to taste
        # Django media
        location /media  {
            alias /sites/mysite/mysite/media;  # your Django project's media files - amend as required
        }
        location /static {
            alias /sites/mysite/mysite/static; # your Django project's static files - amend as required
        }
        # Finally, send all non-media requests to the Django server.
        location / {
            uwsgi_pass   django:8080;
            uwsgi_read_timeout 300;
            include     uwsgi_params;
        }
    }
EOF
```

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '3'
services:
  db:
    image: marketplace.gcr.io/google/postgresql13
    environment:
      - PGDATA=/var/lib/postgresql/data/pgdata
      - POSTGRES_USER=django
      - POSTGRES_PASSWORD=db1234
      - POSTGRES_DB=django
    ports:
      - "127.0.0.1:5432:5432"
    volumes:
      - ./db_data/:/var/lib/postgresql/data
  django:
    image: gcr.io/ccm-ops-test-adhoc/django4:4.1
    depends_on:
    - db
    environment:
      - C2D_DJANGO_SITENAME=mysite
      - C2D_DJANGO_ALLOWED_HOSTS='.localhost', '127.0.0.1', '[::1]'
      - C2D_DJANGO_PORT=8080
      - C2D_DJANGO_DB_TYPE=postgresql
      - C2D_DJANGO_DB_NAME=django
      - C2D_DJANGO_DB_USER=django
      - C2D_DJANGO_DB_PASSWORD=db1234
      - C2D_DJANGO_DB_HOST=db
      - C2D_DJANGO_DB_PORT=5432
      - C2D_DJANGO_MODE=socket
    ports:
      - "127.0.0.1:8080:8080"
      - "127.0.0.1:1717:1717"
  nginx:
    image: marketplace.gcr.io/google/nginx1
    depends_on:
    - django
    ports:
      - "127.0.0.1:8081:8081"
    volumes:
      - $PWD/nginx.conf:/etc/nginx/conf.d/default.conf
```

You should be able to view Django homepage through NGINX at: http://localhost:8081/

# <a name="references"></a> References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
|:-------------|:----------------|
|8080 | Web |
|1717 | Stats |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable** | **Description** |
|:-------------|:----------------|
|C2D_DJANGO_SITENAME| Website name. |
|C2D_DJANGO_PORT| Port where UWSGI runs. |
|C2D_DJANGO_MODE| `socket` (default) or `http`. |
|C2D_DJANGO_ALLOWED_HOSTS| Hosts allowed to perform requests. |
|C2D_DJANGO_DB_TYPE| `postgresql` or `mysql`. |
|C2D_DJANGO_DB_NAME| Database name. |
|C2D_DJANGO_DB_USER| Database user. |
|C2D_DJANGO_DB_PASSWORD| Database password. |
|C2D_DJANGO_DB_HOST| Database host. |
|C2D_DJANGO_DB_PORT| Database port. |


## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description** |
|:---------|:----------------|
|/sites| Django websites are installed here. |
