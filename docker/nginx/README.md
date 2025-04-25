nginx-docker
============

Dockerfile source for nginx [docker](https://docker.io) image.

# Upstream
This source repo was originally copied from:
https://github.com/nginxinc/docker-nginx

# Disclaimer
This is not an official Google product.

# <a name="about"></a>About

This image contains an installation Nginx 1.x.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/details/google/nginx1).

Pull command (first install [gcloud](https://cloud.google.com/sdk/downloads)):

```shell
gcloud auth configure-docker && docker -- pull marketplace.gcr.io/google/nginx1
```

Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/nginx-docker/tree/master/1).

# <a name="table-of-contents"></a>Table of Contents
* [Using Kubernetes](#using-kubernetes)
  * [Running Nginx](#running-nginx-kubernetes)
    * [Start a Nginx web server](#start-a-nginx-web-server-kubernetes)
    * [Use a persistent data volume](#use-a-persistent-data-volume-kubernetes)
  * [Web server configuration](#configuration-kubernetes)
    * [Viewing existing configuration](#viewing-existing-configuration-kubernetes)
    * [Using configuration volume](#using-configuration-volume-kubernetes)
    * [Moving the web content to Nginx](#move-web-content-kubernetes)
  * [Testing the web server](#testing-the-web-server-kubernetes)
    * [Accessing the web server from within the container](#accessing-the-web-server-from-within-the-container-kubernetes)
* [Using Docker](#using-docker)
  * [Running Nginx](#running-nginx-docker)
    * [Start a Nginx web server](#start-a-nginx-web-server-docker)
    * [Use a persistent data volume](#use-a-persistent-data-volume-docker)
  * [Web server configuration](#configuration-docker)
    * [Viewing existing configuration](#viewing-existing-configuration-docker)
    * [Using configuration volume](#using-configuration-volume-docker)
    * [Moving the web content to Nginx](#move-web-content-docker)
  * [Testing the web server](#testing-the-web-server-docker)
    * [Accessing the web server from within the container](#accessing-the-web-server-from-within-the-container-docker)
* [References](#references)
  * [Ports](#references-ports)
  * [Volumes](#references-volumes)

# <a name="using-kubernetes"></a>Using Kubernetes

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Kubernetes environment.

## <a name="running-nginx-kubernetes"></a>Running Nginx

### <a name="start-a-nginx-web-server-kubernetes"></a>Start a Nginx web server

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-nginx
  labels:
    name: some-nginx
spec:
  containers:
    - image: marketplace.gcr.io/google/nginx1
      name: nginx
```

Run the following to expose the ports.
Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-nginx --name some-nginx-80 \
  --type LoadBalancer --port 80 --protocol TCP
kubectl expose pod some-nginx --name some-nginx-443 \
  --type LoadBalancer --port 443 --protocol TCP
```

For information about how to retain your data across restarts, see [Use a persistent data volume](#use-a-persistent-data-volume-kubernetes).

For information about how to configure your web server, see [Web server configuration](#configuration-kubernetes).

### <a name="use-a-persistent-data-volume-kubernetes"></a>Use a persistent data volume

To preserve your web server data when the container restarts, put
the web content directory on a persistent volume.

By default, `/usr/share/nginx/html` directory on the container houses all the web content files.

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-nginx
  labels:
    name: some-nginx
spec:
  containers:
    - image: marketplace.gcr.io/google/nginx1
      name: nginx
      volumeMounts:
        - name: webcontent
          mountPath: /usr/share/nginx/html
  volumes:
    - name: webcontent
      persistentVolumeClaim:
        claimName: webcontent
---
# Request a persistent volume from the cluster using a Persistent Volume Claim.
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: webcontent
  annotations:
    volume.alpha.kubernetes.io/storage-class: default
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 5Gi
```

Run the following to expose the ports.
Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-nginx --name some-nginx-80 \
  --type LoadBalancer --port 80 --protocol TCP
kubectl expose pod some-nginx --name some-nginx-443 \
  --type LoadBalancer --port 443 --protocol TCP
```

The web server configuration should also be on a persistent volume. For more information, see [Web server configuration](#configuration-kubernetes).

## <a name="configuration-kubernetes"></a>Web server configuration

### <a name="viewing-existing-configuration-kubernetes"></a>Viewing existing configuration

Nginx configuration file is at `/etc/nginx/nginx.conf`.

```shell
kubectl exec some-nginx -- cat /etc/nginx/nginx.conf
```

### <a name="using-configuration-volume-kubernetes"></a>Using configuration volume

The default `nginx.conf` includes all configuration files under `/etc/nginx/conf.d` directory. If you have a `/path/to/your/site.conf` file locally, you can start the server as followed to mount it under `conf.d` directory.

Create the following `configmap`:

```shell
kubectl create configmap site-conf \
  --from-file=/path/to/your/site.conf
```

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-nginx
  labels:
    name: some-nginx
spec:
  containers:
    - image: marketplace.gcr.io/google/nginx1
      name: nginx
      volumeMounts:
        - name: site-conf
          mountPath: /etc/nginx/conf.d
  volumes:
    - name: site-conf
      configMap:
        name: site-conf
```

Run the following to expose the ports.
Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-nginx --name some-nginx-80 \
  --type LoadBalancer --port 80 --protocol TCP
kubectl expose pod some-nginx --name some-nginx-443 \
  --type LoadBalancer --port 443 --protocol TCP
```

### <a name="move-web-content-kubernetes"></a>Moving the web content to Nginx

We can move the web content to the container with the commands below, assuming `/usr/share/nginx/html` is where nginx has been configured to read from.

Create the directory if it does not exist yet.

```shell
kubectl exec some-nginx -- mkdir -p /usr/share/nginx/html
```

Copy the `index.html` file.

```shell
kubectl cp /path/to/your/index.html some-nginx:/usr/share/nginx/html/index.html
```

Follow instructions in [Testing the web server](#testing-the-web-server-kubernetes), you should get back the content of your `index.html`.

## <a name="testing-the-web-server-kubernetes"></a>Testing the web server

### <a name="accessing-the-web-server-from-within-the-container-kubernetes"></a>Accessing the web server from within the container

Attach to the webserver.

```shell
kubectl exec -it some-nginx -- bash
```

Install `curl`.

```
apt-get update && apt-get install -y curl
```

We can now use `curl` to see if the webserver returns content.

```
curl http://localhost
```

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="running-nginx-docker"></a>Running Nginx

### <a name="start-a-nginx-web-server-docker"></a>Start a Nginx web server

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  nginx:
    container_name: some-nginx
    image: marketplace.gcr.io/google/nginx1
    ports:
      - '80:80'
      - '443:443'
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-nginx \
  -p 80:80 \
  -p 443:443 \
  -d \
  marketplace.gcr.io/google/nginx1
```

For information about how to retain your data across restarts, see [Use a persistent data volume](#use-a-persistent-data-volume-docker).

For information about how to configure your web server, see [Web server configuration](#configuration-docker).

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

To preserve your web server data when the container restarts, put
the web content directory on a persistent volume.

By default, `/usr/share/nginx/html` directory on the container houses all the web content files.

Also assume that `/my/persistent/dir/www` is the persistent directory on the host.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  nginx:
    container_name: some-nginx
    image: marketplace.gcr.io/google/nginx1
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - /my/persistent/dir/www:/usr/share/nginx/html
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-nginx \
  -p 80:80 \
  -p 443:443 \
  -v /my/persistent/dir/www:/usr/share/nginx/html \
  -d \
  marketplace.gcr.io/google/nginx1
```

The web server configuration should also be on a persistent volume. For more information, see [Web server configuration](#configuration-docker).

## <a name="configuration-docker"></a>Web server configuration

### <a name="viewing-existing-configuration-docker"></a>Viewing existing configuration

Nginx configuration file is at `/etc/nginx/nginx.conf`.

```shell
docker exec some-nginx cat /etc/nginx/nginx.conf
```

### <a name="using-configuration-volume-docker"></a>Using configuration volume

The default `nginx.conf` includes all configuration files under `/etc/nginx/conf.d` directory. If you have a `/path/to/your/site.conf` file locally, you can start the server as followed to mount it under `conf.d` directory.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  nginx:
    container_name: some-nginx
    image: marketplace.gcr.io/google/nginx1
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - /path/to/your/site.conf:/etc/nginx/conf.d/site.conf
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-nginx \
  -p 80:80 \
  -p 443:443 \
  -v /path/to/your/site.conf:/etc/nginx/conf.d/site.conf \
  -d \
  marketplace.gcr.io/google/nginx1
```

### <a name="move-web-content-docker"></a>Moving the web content to Nginx

We can move the web content to the container with the commands below, assuming `/usr/share/nginx/html` is where nginx has been configured to read from.

Create the directory if it does not exist yet.

```shell
docker exec some-nginx mkdir -p /usr/share/nginx/html
```

Copy the `index.html` file.

```shell
docker cp /path/to/your/index.html some-nginx:/usr/share/nginx/html/index.html
```

Follow instructions in [Testing the web server](#testing-the-web-server-docker), you should get back the content of your `index.html`.

## <a name="testing-the-web-server-docker"></a>Testing the web server

### <a name="accessing-the-web-server-from-within-the-container-docker"></a>Accessing the web server from within the container

Attach to the webserver.

```shell
docker exec -it some-nginx bash
```

Install `curl`.

```
apt-get update && apt-get install -y curl
```

We can now use `curl` to see if the webserver returns content.

```
curl http://localhost
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
|:---------|:----------------|
| TCP 80 | Nginx http default port |
| TCP 443 | Nginx https secure connection over SSL |
| TCP 9113 | Prometheus metrics exporter |

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description** |
|:---------|:----------------|
| /etc/nginx | Contains nginx configuration files, including `nginx.conf`. <br><br> The default `nginx.conf` include all `.conf` files under the subdirectory `conf.d`. |
