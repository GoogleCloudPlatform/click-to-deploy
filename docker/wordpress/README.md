wordpress-docker
============

Dockerfile source for WordPress [docker](https://docker.io) image.

# Upstream

This source repo was originally copied from:
https://github.com/docker-library/wordpress

# Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of WordPress served by an Apache HTTP
Server on a PHP runtime.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/details/google/wordpress5-php7-apache).

Pull command (first install [gcloud](https://cloud.google.com/sdk/downloads)):

```shell
gcloud auth configure-docker && docker -- pull marketplace.gcr.io/google/wordpress5-php7-apache
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/wordpress-docker/tree/master/5/php7/debian9/apache).
=======

# <a name="table-of-contents"></a>Table of Contents
* [Using Kubernetes](#using-kubernetes)
  * [Running WordPress](#running-wordpress-kubernetes)
    * [Run WordPress and MySQL containers](#run-wordpress-and-mysql-containers-kubernetes)
    * [Run WordPress connecting to an external MySQL service](#run-wordpress-connecting-to-an-external-mysql-service-kubernetes)
    * [Run with persistent data volumes](#run-with-persistent-data-volumes-kubernetes)
* [Using Docker](#using-docker)
  * [Running WordPress](#running-wordpress-docker)
    * [Run WordPress and MySQL containers](#run-wordpress-and-mysql-containers-docker)
    * [Run WordPress connecting to an external MySQL service](#run-wordpress-connecting-to-an-external-mysql-service-docker)
    * [Run with persistent data volumes](#run-with-persistent-data-volumes-docker)
  * [Customizing WordPress](#customizing-wordpress-docker)
    * [Install additional PHP extensions](#install-additional-php-extensions-docker)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-kubernetes"></a>Using Kubernetes

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Kubernetes environment.

## <a name="running-wordpress-kubernetes"></a>Running WordPress

This section describes how to spin up a Wordpress service using this image.

### <a name="run-wordpress-and-mysql-containers-kubernetes"></a>Run WordPress and MySQL containers

WordPress requires a separate MySQL service which can be run in another container.

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-wordpress
  labels:
    name: some-wordpress
spec:
  containers:
    - image: marketplace.gcr.io/google/wordpress5-php7-apache
      name: wordpress
      env:
        - name: "WORDPRESS_DB_HOST"
          value: "127.0.0.1:3306"
        - name: "WORDPRESS_DB_PASSWORD"
          value: "example-password"
    - image: marketplace.gcr.io/google/mysql5
      name: mysql
      env:
        - name: "MYSQL_ROOT_PASSWORD"
          value: "example-password"
```

Run the following to expose the port.
Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-wordpress --name some-wordpress-80 \
  --type LoadBalancer --port 80 --protocol TCP
```

For information about how to retain your Wordpress installation across restarts, see [Run with persistent data volumes](#run-with-persistent-data-volumes-kubernetes).

### <a name="run-wordpress-connecting-to-an-external-mysql-service-kubernetes"></a>Run WordPress connecting to an external MySQL service

Instead of spinning up a MySQL container, we can connect Wordpress to any running MySQL database instance (assumed to be running at `some.mysql.host`) by specifying its hostname via environment variable `WORDPRESS_DB_HOST`. Database username and password also have to be explicitly specified to connect to the database instance via `WORDPRESS_DB_USER` and `WORDPRESS_DB_PASSWORD`.

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-wordpress
  labels:
    name: some-wordpress
spec:
  containers:
    - image: marketplace.gcr.io/google/wordpress5-php7-apache
      name: wordpress
      env:
        - name: "WORDPRESS_DB_HOST"
          value: "some.mysql.host:3306"
        - name: "WORDPRESS_DB_PASSWORD"
          value: "example-password"
        - name: "WORDPRESS_DB_USER"
          value: "root"
```

Run the following to expose the port.
Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-wordpress --name some-wordpress-80 \
  --type LoadBalancer --port 80 --protocol TCP
```

### <a name="run-with-persistent-data-volumes-kubernetes"></a>Run with persistent data volumes

We can store data on persistent volumes for both MySQL and WordPress. This way the installation remains intact across restarts.

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-wordpress
  labels:
    name: some-wordpress
spec:
  containers:
    - image: marketplace.gcr.io/google/wordpress5-php7-apache
      name: wordpress
      env:
        - name: "WORDPRESS_DB_HOST"
          value: "127.0.0.1:3306"
        - name: "WORDPRESS_DB_PASSWORD"
          value: "example-password"
      volumeMounts:
        - name: wordpress-data
          mountPath: /var/www/html
          subPath: wp
    - image: marketplace.gcr.io/google/mysql5
      name: mysql
      env:
        - name: "MYSQL_ROOT_PASSWORD"
          value: "example-password"
      volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
          subPath: db
  volumes:
    - name: wordpress-data
      persistentVolumeClaim:
        claimName: wordpress-data
    - name: mysql-data
      persistentVolumeClaim:
        claimName: mysql-data
---
# Request a persistent volume from the cluster using a Persistent Volume Claim.
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: wordpress-data
  annotations:
    volume.alpha.kubernetes.io/storage-class: default
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 5Gi
---
# Request a persistent volume from the cluster using a Persistent Volume Claim.
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mysql-data
  annotations:
    volume.alpha.kubernetes.io/storage-class: default
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 5Gi
```

Run the following to expose the port.
Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-wordpress --name some-wordpress-80 \
  --type LoadBalancer --port 80 --protocol TCP
```

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-wordpress-docker"></a>Running WordPress

This section describes how to spin up a Wordpress service using this image.

### <a name="run-wordpress-and-mysql-containers-docker"></a>Run WordPress and MySQL containers

WordPress requires a separate MySQL service which can be run in another container.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  wordpress:
    container_name: some-wordpress
    image: marketplace.gcr.io/google/wordpress5-php7-apache
    environment:
      "WORDPRESS_DB_PASSWORD": "example-password"
    ports:
      - '8080:80'
    depends_on:
      - mysql
  mysql:
    image: marketplace.gcr.io/google/mysql5
    environment:
      "MYSQL_ROOT_PASSWORD": "example-password"
```

Or you can use `docker run` directly:

```shell
# mysql
docker run \
  --name some-mysql \
  -e "MYSQL_ROOT_PASSWORD=example-password" \
  -d \
  marketplace.gcr.io/google/mysql5

# wordpress
docker run \
  --name some-wordpress \
  -p 8080:80 \
  --link some-mysql:mysql \
  -d \
  marketplace.gcr.io/google/wordpress5-php7-apache
```

WordPress will be accessible on your localhost at `http://localhost:8080/`.

For information about how to retain your Wordpress installation across restarts, see [Run with persistent data volumes](#run-with-persistent-data-volumes-docker).

### <a name="run-wordpress-connecting-to-an-external-mysql-service-docker"></a>Run WordPress connecting to an external MySQL service

Instead of spinning up a MySQL container, we can connect WordPress to any running MySQL database instance (assumed to be running at `some.mysql.host`) by specifying its hostname via environment variable `WORDPRESS_DB_HOST`. Database username and password also have to be explicitly specified to connect to the database instance via `WORDPRESS_DB_USER` and `WORDPRESS_DB_PASSWORD`.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  wordpress:
    container_name: some-wordpress
    image: marketplace.gcr.io/google/wordpress5-php7-apache
    environment:
      "WORDPRESS_DB_HOST": "some.mysql.host:3306"
      "WORDPRESS_DB_PASSWORD": "example-password"
      "WORDPRESS_DB_USER": "root"
    ports:
      - '8080:80'
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-wordpress \
  -e "WORDPRESS_DB_HOST=some.mysql.host:3306" \
  -e "WORDPRESS_DB_PASSWORD=example-password" \
  -e "WORDPRESS_DB_USER=root" \
  -p 8080:80 \
  -d \
  marketplace.gcr.io/google/wordpress5-php7-apache
```

### <a name="run-with-persistent-data-volumes-docker"></a>Run with persistent data volumes

We can store data on persistent volumes for both MySQL and WordPress. This way the installation remains intact across restarts. Assume that `/my/persistent/dir/wordpress` and `/my/persistent/dir/mysql` are the two persistent directories on the host.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  wordpress:
    container_name: some-wordpress
    image: marketplace.gcr.io/google/wordpress5-php7-apache
    environment:
      "WORDPRESS_DB_PASSWORD": "example-password"
    ports:
      - '8080:80'
    volumes:
      - /my/persistent/dir/wordpress:/var/www/html
    depends_on:
      - mysql
  mysql:
    image: marketplace.gcr.io/google/mysql5
    environment:
      "MYSQL_ROOT_PASSWORD": "example-password"
    volumes:
      - /my/persistent/dir/mysql:/var/lib/mysql
```

Or you can use `docker run` directly:

```shell
# mysql
docker run \
  --name some-mysql \
  -e "MYSQL_ROOT_PASSWORD=example-password" \
  -v /my/persistent/dir/mysql:/var/lib/mysql \
  -d \
  marketplace.gcr.io/google/mysql5

# wordpress
docker run \
  --name some-wordpress \
  -p 8080:80 \
  -v /my/persistent/dir/wordpress:/var/www/html \
  --link some-mysql:mysql \
  -d \
  marketplace.gcr.io/google/wordpress5-php7-apache
```

## <a name="customizing-wordpress-docker"></a>Customizing WordPress

### <a name="install-additional-php-extensions-docker"></a>Install additional PHP extensions

To keep the image size small, this image doesn’t include additional PHP extensions.

If you need to install additional PHP extensions, for example because a plugin requires them, you can extend the image as follows.

Use the following content for the `Dockerfile` file:

```dockerfile
FROM marketplace.gcr.io/google/wordpress5-php7-apache
RUN apt-get update \
  && apt-get install -y libmcrypt-dev \
  && docker-php-ext-install mcrypt
```

Then build the image with:

```shell
docker build -t my-wordpress5-php7-apache
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
|:---------|:----------------|
| TCP 80 | Standard HTTP port. |
| TCP 443 | Standard HTTPS port. |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable** | **Description** |
|:-------------|:----------------|
| WORDPRESS_DB_HOST | Host name and port of MySQL service. If a MySQL container is linked, defaults to its IP and port. |
| WORDPRESS_DB_USER | The user name used for accessing the database. Defaults to "root". |
| WORDPRESS_DB_PASSWORD | The password used for accessing the database for the user defined in `WORDPRESS_DB_USER`. If a MySQL container is linked, defaults to its `MYSQL_ROOT_PASSWORD` value. |
| WORDPRESS_DB_NAME | Defaults to "wordpress". <br><br> If the `WORDPRESS_DB_NAME` specified does not already exist on the given MySQL server, it will be created automatically upon startup of the wordpress container, provided that the `WORDPRESS_DB_USER` specified has the necessary permissions to create it. |
| WORDPRESS_TABLE_PREFIX | Default is empty. |
| WORDPRESS_AUTH_KEY | Defaults to a unique random SHA1. |
| WORDPRESS_SECURE_AUTH_KEY | Defaults to a unique random SHA1. |
| WORDPRESS_LOGGED_IN_KEY | Defaults to a unique random SHA1. |
| WORDPRESS_NONCE_KEY | Defaults to a unique random SHA1. |
| WORDPRESS_AUTH_SALT | Defaults to a unique random SHA1. |
| WORDPRESS_SECURE_AUTH_SALT | Defaults to a unique random SHA1. |
| WORDPRESS_LOGGED_IN_SALT | Defaults to a unique random SHA1. |
| WORDPRESS_NONCE_SALT | Defaults to a unique random SHA1. |

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description** |
|:---------|:----------------|
| /var/www/html | All Wordpress files are installed here. |
| /var/www/html/wp-content | The most important folder containing user uploaded data, themes, and plugins. This folder and the MySQL database contain the full state of your Wordpress installation. |
