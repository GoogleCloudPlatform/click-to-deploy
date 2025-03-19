rabbitmq-docker
============

Dockerfile source for RabbitMQ [docker](https://docker.io) image.

# Upstream
This source repo was originally copied from:
https://github.com/docker-library/rabbitmq

For Upstream documentation visit:
https://github.com/docker-library/docs/tree/master/rabbitmq

# Disclaimer
This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of RabbitMQ 3.x.

For more information, see the [Official Image Marketplace Page](https://console.cloud.google.com/marketplace/details/google/rabbitmq3).

Pull command:

```shell
gcloud docker -- pull marketplace.gcr.io/google/rabbitmq3
```

Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/rabbitmq-docker/tree/master/3).

# <a name="table-of-contents"></a>Table of Contents
* [Using Kubernetes](#using-kubernetes)
  * [Running RabbitMQ](#running-rabbitmq-kubernetes)
    * [Starting a RabbitMQ instance](#starting-a-rabbitmq-instance-kubernetes)
    * [Connecting to a running RabbitMQ container](#connecting-to-a-running-rabbitmq-container-kubernetes)
  * [Adding persistence](#adding-persistence-kubernetes)
    * [Running with persistent data volumes](#running-with-persistent-data-volumes-kubernetes)
* [Using Docker](#using-docker)
  * [Running RabbitMQ](#running-rabbitmq-docker)
    * [Starting a RabbitMQ instance](#starting-a-rabbitmq-instance-docker)
    * [Connecting to a running RabbitMQ container](#connecting-to-a-running-rabbitmq-container-docker)
  * [Adding persistence](#adding-persistence-docker)
    * [Running with persistent data volumes](#running-with-persistent-data-volumes-docker)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-kubernetes"></a>Using Kubernetes

## <a name="running-rabbitmq-kubernetes"></a>Running RabbitMQ

### <a name="starting-a-rabbitmq-instance-kubernetes"></a>Starting a RabbitMQ instance

Replace `your-erlang-cookie` with a valid cookie value. For more information, see `RABBITMQ_ERLANG_COOKIE` in [Environment Variable](#references-environment-variables).

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-rabbitmq
  labels:
    name: some-rabbitmq
spec:
  containers:
    - image: marketplace.gcr.io/google/rabbitmq3
      name: rabbitmq
      env:
        - name: "RABBITMQ_ERLANG_COOKIE"
          value: "unique-erlang-cookie"
```

Run the following to expose the ports:

```shell
kubectl expose pod some-rabbitmq --name some-rabbitmq-4369 \
  --type LoadBalancer --port 4369 --protocol TCP
kubectl expose pod some-rabbitmq --name some-rabbitmq-5671 \
  --type LoadBalancer --port 5671 --protocol TCP
kubectl expose pod some-rabbitmq --name some-rabbitmq-5672 \
  --type LoadBalancer --port 5672 --protocol TCP
kubectl expose pod some-rabbitmq --name some-rabbitmq-25672 \
  --type LoadBalancer --port 25672 --protocol TCP
```

For information about how to retain your RabbitMQ data across container restarts, see [Adding persistence](#adding-persistence-kubernetes).

### <a name="connecting-to-a-running-rabbitmq-container-kubernetes"></a>Connecting to a running RabbitMQ container

Open an interactive shell to the RabbitMQ container. Note that because we open a shell directly in the container, Erlang cookie does not have to be explicitly specified.

```shell
kubectl exec -it some-rabbitmq -- /bin/bash
```

`rabbitmqctl` can be run in the shell. For example, we can do a node health check.

```
rabbitmqctl node_health_check
```

## <a name="adding-persistence-kubernetes"></a>Adding persistence

### <a name="running-with-persistent-data-volumes-kubernetes"></a>Running with persistent data volumes

We can store data on persistent volumes, this way the installation remains intact across restarts.

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-rabbitmq
  labels:
    name: some-rabbitmq
spec:
  containers:
    - image: marketplace.gcr.io/google/rabbitmq3
      name: rabbitmq
      env:
        - name: "RABBITMQ_ERLANG_COOKIE"
          value: "unique-erlang-cookie"
      volumeMounts:
        - name: rabbitmq-data
          mountPath: /var/lib/rabbitmq
  volumes:
    - name: rabbitmq-data
      persistentVolumeClaim:
        claimName: rabbitmq-data
---
# Request a persistent volume from the cluster using a Persistent Volume Claim.
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: rabbitmq-data
  annotations:
    volume.alpha.kubernetes.io/storage-class: default
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 5Gi
```

Run the following to expose the ports:

```shell
kubectl expose pod some-rabbitmq --name some-rabbitmq-4369 \
  --type LoadBalancer --port 4369 --protocol TCP
kubectl expose pod some-rabbitmq --name some-rabbitmq-5671 \
  --type LoadBalancer --port 5671 --protocol TCP
kubectl expose pod some-rabbitmq --name some-rabbitmq-5672 \
  --type LoadBalancer --port 5672 --protocol TCP
kubectl expose pod some-rabbitmq --name some-rabbitmq-25672 \
  --type LoadBalancer --port 25672 --protocol TCP
```

# <a name="using-docker"></a>Using Docker

## <a name="running-rabbitmq-docker"></a>Running RabbitMQ

### <a name="starting-a-rabbitmq-instance-docker"></a>Starting a RabbitMQ instance

Replace `your-erlang-cookie` with a valid cookie value. For more information, see `RABBITMQ_ERLANG_COOKIE` in [Environment Variable](#references-environment-variables).

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  rabbitmq:
    container_name: some-rabbitmq
    image: marketplace.gcr.io/google/rabbitmq3
    environment:
      "RABBITMQ_ERLANG_COOKIE": "unique-erlang-cookie"
    ports:
      - '4369:4369'
      - '5671:5671'
      - '5672:5672'
      - '25672:25672'
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-rabbitmq \
  -e "RABBITMQ_ERLANG_COOKIE=unique-erlang-cookie" \
  -p 4369:4369 \
  -p 5671:5671 \
  -p 5672:5672 \
  -p 25672:25672 \
  -d \
  marketplace.gcr.io/google/rabbitmq3
```

For information about how to retain your RabbitMQ data across container restarts, see [Adding persistence](#adding-persistence-docker).

### <a name="connecting-to-a-running-rabbitmq-container-docker"></a>Connecting to a running RabbitMQ container

Open an interactive shell to the RabbitMQ container. Note that because we open a shell directly in the container, Erlang cookie does not have to be explicitly specified.

```shell
docker exec -it some-rabbitmq /bin/bash
```

`rabbitmqctl` can be run in the shell. For example, we can do a node health check.

```
rabbitmqctl node_health_check
```

## <a name="adding-persistence-docker"></a>Adding persistence

### <a name="running-with-persistent-data-volumes-docker"></a>Running with persistent data volumes

We can store data on persistent volumes, this way the installation remains intact across restarts. Assume that `/path/to/your/rabbitmq` is the persistent directory on the host.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  rabbitmq:
    container_name: some-rabbitmq
    image: marketplace.gcr.io/google/rabbitmq3
    environment:
      "RABBITMQ_ERLANG_COOKIE": "unique-erlang-cookie"
    ports:
      - '4369:4369'
      - '5671:5671'
      - '5672:5672'
      - '25672:25672'
    volumes:
      - /path/to/your/rabbitmq:/var/lib/rabbitmq
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-rabbitmq \
  -e "RABBITMQ_ERLANG_COOKIE=unique-erlang-cookie" \
  -p 4369:4369 \
  -p 5671:5671 \
  -p 5672:5672 \
  -p 25672:25672 \
  -v /path/to/your/rabbitmq:/var/lib/rabbitmq \
  -d \
  marketplace.gcr.io/google/rabbitmq3
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
|:---------|:----------------|
| TCP 4369 | [`epmd` port](http://erlang.org/doc/man/epmd.html), a peer discovery service used by RabbitMQ nodes and CLI tools. |
| TCP 5671 | Used by AMQP 0-9-1 and 1.0 clients with TLS. |
| TCP 5672 | Used by AMQP 0-9-1 and 1.0 clients without TLS. |
| TCP 25672 | Used by Erlang distribution for inter-node and CLI tools communication. This port is allocated from a dynamic range. By default, it takes the value of AMQP port plus 20000 (5672 + 20000), or 25672. |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable** | **Description** |
|:-------------|:----------------|
| RABBITMQ_ERLANG_COOKIE | Sets the shared secret Erlang cookie used for authenticating other nodes and clients. For two nodes, or a node and a client, to communicate with each other, they must have the same Erlang cookie. |
| RABBITMQ_DEFAULT_USER | Sets the default user name. Used in conjunction with `RABBITMQ_DEFAULT_PASS`. <br><br> Defaults to `guest`. |
| RABBITMQ_DEFAULT_PASS | Sets the default user password. Used in conjunction with `RABBITMQ_DEFAULT_USER`. <br><br> Defaults to `guest`. |

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description** |
|:---------|:----------------|
| /var/lib/rabbitmq | All RabbitMQ files are installed here. |

