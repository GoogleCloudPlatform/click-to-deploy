# <a name="about"></a>About

This image contains an installation Memcached 1.x.

For more information, see the [Official Image Launcher Page](https://console.cloud.google.com/launcher/details/google/memcached1).

Pull command (first install [gcloud](https://cloud.google.com/sdk/downloads)):

```shell
gcloud docker -- pull launcher.gcr.io/google/memcached1
```

Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/memcached-docker/tree/master/1).

# <a name="table-of-contents"></a>Table of Contents
* [Using Kubernetes](#using-kubernetes)
  * [Running Memcached](#running-memcached-kubernetes)
    * [Starting a Memcached instance](#starting-a-memcached-instance-kubernetes)
  * [Memcached CLI](#memcached-cli-1-kubernetes)
    * [Connecting to a running Memcached container](#connecting-to-a-running-memcached-container-1-kubernetes)
  * [Configuring Memcached](#configuring-memcached-kubernetes)
    * [Changing RAM value for item storage](#changing-ram-value-for-item-storage-kubernetes)
* [Using Docker](#using-docker)
  * [Running Memcached](#running-memcached-docker)
    * [Starting a Memcached instance](#starting-a-memcached-instance-docker)
  * [Memcached CLI](#memcached-cli-docker)
    * [Connecting to a running Memcached container](#connecting-to-a-running-memcached-container-docker)
  * [Configuring Memcached](#configuring-memcached-docker)
    * [Changing RAM value for item storage](#changing-ram-value-for-item-storage-docker)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)

# <a name="using-kubernetes"></a>Using Kubernetes

Consult [Launcher container documentation](https://cloud.google.com/launcher/docs/launcher-container)
for additional information about setting up your Kubernetes environment.

## <a name="running-memcached-kubernetes"></a>Running Memcached

### <a name="starting-a-memcached-instance-kubernetes"></a>Starting a Memcached instance

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-memcached
  labels:
    name: some-memcached
spec:
  containers:
    - image: launcher.gcr.io/google/memcached1
      name: memcached
```

Run the following to expose the port.
Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-memcached --name some-memcached-11211 \
  --type LoadBalancer --port 11211 --protocol TCP
```

## <a name="memcached-cli-1-kubernetes"></a>Memcached CLI

### <a name="connecting-to-a-running-memcached-container-1-kubernetes"></a>Connecting to a running Memcached container

Memcached does not provide specific client. However, standard tools like telnet are enough to test container. Under Linux it is possible to connect by CLI command. We can invoke `telnet` from host machine, to connect to running Memcached server

```shell
telnet $MEMCACHED_SERVER_IP 11211
```

If we try to connect to memcached running in Kubernetes cluster, we can invoke

```shell
export MEMCACHED_ENDPOINT_IP=$(kubectl describe services some-memcached | awk '/LoadBalancer Ingress:/ {print $3}')
telnet $MEMCACHED_ENDPOINT_IP 11211
```

To test if Memcached is working we create a key called MY_TEST_KEY. Run the following command to set a test key.

```shell
set MY_TEST_KEY 0 60 4
pass
```

Run the following command to verify that the set command above succeeded. This should print out `pass`.

```shell
get MY_TEST_KEY
```

## <a name="configuring-memcached-kubernetes"></a>Configuring Memcached

Memcached is configuring by arguments provided at the start of running a container.
Arguments can be checked in
[documentation](https://github.com/memcached/memcached/wiki/ConfiguringServer)
or by reading help from `-h` argument.

### <a name="changing-ram-value-for-item-storage-kubernetes"></a>Changing RAM value for item storage

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-memcached
  labels:
    name: some-memcached
spec:
  containers:
    - image: launcher.gcr.io/google/memcached1
      name: memcached
      args:
        - '-m 256'
```

Run the following to expose the port.
Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-memcached --name some-memcached-11211 \
  --type LoadBalancer --port 11211 --protocol TCP
```

# <a name="using-docker"></a>Using Docker

Consult [Launcher container documentation](https://cloud.google.com/launcher/docs/launcher-container)
for additional information about setting up your Docker environment.

## <a name="running-memcached-docker"></a>Running Memcached

### <a name="starting-a-memcached-instance-docker"></a>Starting a Memcached instance

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  memcached:
    container_name: some-memcached
    image: launcher.gcr.io/google/memcached1
    ports:
      - '11211:11211'
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-memcached \
  -p 11211:11211 \
  -d \
  launcher.gcr.io/google/memcached1
```

## <a name="memcached-cli-docker"></a>Memcached CLI

### <a name="connecting-to-a-running-memcached-container-docker"></a>Connecting to a running Memcached container

Memcached does not provide specific client. However, standard tools like telnet are enough to test container. Under Linux it is possible to connect by CLI command. We can invoke `telnet` from host machine, to connect to running Memcached server

```shell
telnet $MEMCACHED_SERVER_IP 11211
```

If we try to connect to locally running container, we can invoke

```shell
telnet localhost 11211
```

To test if Memcached is working we create a key called MY_TEST_KEY. Run the following command to set a test key.

```shell
set MY_TEST_KEY 0 60 4
pass
```

Run the following command to verify that the set command above succeeded. This should print out `pass`.

```shell
get MY_TEST_KEY
```

## <a name="configuring-memcached-docker"></a>Configuring Memcached

Memcached is configuring by arguments provided at the start of running a container.
Arguments can be checked in
[documentation](https://github.com/memcached/memcached/wiki/ConfiguringServer)
or by reading help from `-h` argument.

### <a name="changing-ram-value-for-item-storage-docker"></a>Changing RAM value for item storage

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  memcached:
    container_name: some-memcached
    image: launcher.gcr.io/google/memcached1
    command:
      - '-m 256'
    ports:
      - '11211:11211'
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-memcached \
  -p 11211:11211 \
  -d \
  launcher.gcr.io/google/memcached1 \
  '-m 256'
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
|:---------|:----------------|
| TCP 9150 | Prometheus plugin port. |
| TCP 11211 | Memcached port. |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable** | **Description** |
|:-------------|:----------------|
| MEMCACHED_PROMETHEUS_ENABLED | Specifies if Prometheus metrics should be visible. <br><br> If set to `true`, this variable adds [Memcached Exporter](https://github.com/prometheus/memcached_exporter) as an additional process running in container. Metrics are available under local endpoint http://localhost:9150/metrics. |
