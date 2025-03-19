cassandra-docker
============

Dockerfile source for cassandra [docker](https://docker.io) image.

# Upstream

This source repo was originally copied from:
https://github.com/docker-library/cassandra

# Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Cassandra 3

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/details/google/cassandra3).

Pull command (first install [gcloud](https://cloud.google.com/sdk/downloads)):

```shell
gcloud docker -- pull marketplace.gcr.io/google/cassandra3
```

Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/cassandra-docker/tree/master/3).

# <a name="table-of-contents"></a>Table of Contents
* [Using Kubernetes](#using-kubernetes)
  * [Run a Cassandra server](#run-a-cassandra-server-kubernetes)
    * [Start a single Cassandra container](#start-a-single-cassandra-container-kubernetes)
    * [Connect with Cassandra client (cqlsh)](#connect-with-cassandra-client-cqlsh-kubernetes)
  * [Add persistence](#add-persistence-kubernetes)
    * [Run with persistent data volumes](#run-with-persistent-data-volumes-kubernetes)
* [Using Docker](#using-docker)
  * [Run a Cassandra server](#run-a-cassandra-server-docker)
    * [Start a single Cassandra container](#start-a-single-cassandra-container-docker)
    * [Connect with Cassandra client (cqlsh)](#connect-with-cassandra-client-cqlsh-docker)
  * [Add persistence](#add-persistence-docker)
    * [Run with persistent data volumes](#run-with-persistent-data-volumes-docker)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-kubernetes"></a>Using Kubernetes

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Kubernetes environment.

## <a name="run-a-cassandra-server-kubernetes"></a>Run a Cassandra server

This section describes how to spin up Cassandra service using this image.

### <a name="start-a-single-cassandra-container-kubernetes"></a>Start a single Cassandra container

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-cassandra
  labels:
    name: some-cassandra
spec:
  containers:
    - image: marketplace.gcr.io/google/cassandra3
      name: cassandra
```

Run the following to expose the ports.
Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-cassandra --name some-cassandra-7000 \
  --type LoadBalancer --port 7000 --protocol TCP
kubectl expose pod some-cassandra --name some-cassandra-7001 \
  --type LoadBalancer --port 7001 --protocol TCP
kubectl expose pod some-cassandra --name some-cassandra-7199 \
  --type LoadBalancer --port 7199 --protocol TCP
kubectl expose pod some-cassandra --name some-cassandra-9042 \
  --type LoadBalancer --port 9042 --protocol TCP
kubectl expose pod some-cassandra --name some-cassandra-9160 \
  --type LoadBalancer --port 9160 --protocol TCP
kubectl expose pod some-cassandra --name some-cassandra-9404 \
  --type LoadBalancer --port 9404 --protocol TCP
```

For information about how to retain your Cassandra data across restarts, see [Add persistence](#add-persistence-kubernetes).

### <a name="connect-with-cassandra-client-cqlsh-kubernetes"></a>Connect with Cassandra client (cqlsh)

You can run `cqlsh` directly within the container.

```shell
kubectl exec -it some-cassandra -- cqlsh
```

## <a name="add-persistence-kubernetes"></a>Add persistence

### <a name="run-with-persistent-data-volumes-kubernetes"></a>Run with persistent data volumes

We can mount Cassandra data directory `/var/lib/cassandra` on a persistent volume. This way the installation remains intact across container restarts.

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-cassandra
  labels:
    name: some-cassandra
spec:
  containers:
    - image: marketplace.gcr.io/google/cassandra3
      name: cassandra
      volumeMounts:
        - name: cassandra-data
          mountPath: /var/lib/cassandra
  volumes:
    - name: cassandra-data
      persistentVolumeClaim:
        claimName: cassandra-data
---
# Request a persistent volume from the cluster using a Persistent Volume Claim.
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: cassandra-data
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
kubectl expose pod some-cassandra --name some-cassandra-7000 \
  --type LoadBalancer --port 7000 --protocol TCP
kubectl expose pod some-cassandra --name some-cassandra-7001 \
  --type LoadBalancer --port 7001 --protocol TCP
kubectl expose pod some-cassandra --name some-cassandra-7199 \
  --type LoadBalancer --port 7199 --protocol TCP
kubectl expose pod some-cassandra --name some-cassandra-9042 \
  --type LoadBalancer --port 9042 --protocol TCP
kubectl expose pod some-cassandra --name some-cassandra-9160 \
  --type LoadBalancer --port 9160 --protocol TCP
kubectl expose pod some-cassandra --name some-cassandra-9404 \
  --type LoadBalancer --port 9404 --protocol TCP
```

# <a name="using-docker"></a>Using Docker


Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)

for additional information about setting up your Docker environment.

## <a name="run-a-cassandra-server-docker"></a>Run a Cassandra server

This section describes how to spin up Cassandra service using this image.

### <a name="start-a-single-cassandra-container-docker"></a>Start a single Cassandra container

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  cassandra:
    container_name: some-cassandra
    image: marketplace.gcr.io/google/cassandra3
    ports:
      - '7000:7000'
      - '7001:7001'
      - '7199:7199'
      - '9042:9042'
      - '9160:9160'
      - '9404:9404'
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-cassandra \
  -p 7000:7000 \
  -p 7001:7001 \
  -p 7199:7199 \
  -p 9042:9042 \
  -p 9160:9160 \
  -p 9404:9404 \
  -d \
  marketplace.gcr.io/google/cassandra3
```

For information about how to retain your Cassandra data across restarts, see [Add persistence](#add-persistence-docker).

### <a name="connect-with-cassandra-client-cqlsh-docker"></a>Connect with Cassandra client (cqlsh)

You can run `cqlsh` directly within the container.

```shell
docker exec -it some-cassandra cqlsh
```

## <a name="add-persistence-docker"></a>Add persistence

### <a name="run-with-persistent-data-volumes-docker"></a>Run with persistent data volumes

We can mount Cassandra data directory `/var/lib/cassandra` on a persistent volume. This way the installation remains intact across container restarts.

Assume that `/path/to/your/cassandra` is the persistent directory on the host.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  cassandra:
    container_name: some-cassandra
    image: marketplace.gcr.io/google/cassandra3
    ports:
      - '7000:7000'
      - '7001:7001'
      - '7199:7199'
      - '9042:9042'
      - '9160:9160'
      - '9404:9404'
    volumes:
      - /path/to/your/cassandra:/var/lib/cassandra
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-cassandra \
  -p 7000:7000 \
  -p 7001:7001 \
  -p 7199:7199 \
  -p 9042:9042 \
  -p 9160:9160 \
  -p 9404:9404 \
  -v /path/to/your/cassandra:/var/lib/cassandra \
  -d \
  marketplace.gcr.io/google/cassandra3
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
|:---------|:----------------|
| TCP 7000 | Cassandra inter-node cluster communication. |
| TCP 7001 | Cassandra SSL inter-node cluster communication. |
| TCP 7199 | Cassandra JMX monitoring port. |
| TCP 9042 | Cassandra client port. |
| TCP 9160 | Cassandra Thrift client port. |
| TCP 9404 | Prometheus plugin port. |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable** | **Description** |
|:-------------|:----------------|
| CASSANDRA_LISTEN_ADDRESS | Specifies which IP address to listen on for incoming connections. Defaults to `auto`, which will use the IP address of the container. <br><br> This variable sets the `listen_address` option in `cassandra.yaml`. |
| CASSANDRA_BROADCAST_ADDRESS | Specifies which IP address to advertise to other nodes. Defaults to the value of `CASSANDRA_LISTEN_ADDRESS`. <br><br> This variable sets the `broadcast_address` and `broadcast_rpc_address` options in `cassandra.yaml`. |
| CASSANDRA_RPC_ADDRESS | Specifies which address to bind the thrift rpc server to. Defaults to `0.0.0.0` wildcard address. <br><br> This variable sets the `rpc_address` option in `cassandra.yaml`. |
| CASSANDRA_START_RPC | Specifies starting the thrift rpc server if set to `true`. <br><br> This variable sets the `start_rpc` option in `cassandra.yaml`. |
| CASSANDRA_SEEDS | Specifies a comma-separated list of IP addresses used by gossip for bootstrapping new nodes joining a cluster. The value of `CASSANDRA_BROADCAST_ADDRESS` is automatically added to the list so that the server can also talk to itself. <br><br> This variable sets the `seeds` value of the `seed_provider` option in `cassandra.yaml`. |
| CASSANDRA_CLUSTER_NAME | Specifies the name of the cluster. This value must be the same for all nodes in the same cluster. <br><br> This variable sets the `cluster_name` option in `cassandra.yaml`. |
| CASSANDRA_NUM_TOKENS | Specifies number of tokens for this node. <br><br> This variable sets the `num_tokens` option of `cassandra.yaml`. |
| CASSANDRA_DC | Specifies the datacenter name of this node. <br><br> This variable sets the `dc` option in `cassandra-rackdc.properties`. |
| CASSANDRA_RACK | Specifies the rack name of this node. <br><br> This variable sets the `rack` option in `cassandra-rackdc.properties`. |
| CASSANDRA_ENDPOINT_SNITCH | Specifies the snitch implementation this node will use. <br><br> This variable sets the `endpoint_snitch` option in `cassandra.yml`. |
| CASSANDRA_PROMETHEUS_ENABLED | Specifies if Prometheus metrics should be visible. <br><br> If set to `true`, this variable adds [JMX Exporter](https://github.com/prometheus/jmx_exporter) as a Java agent in `$JVM_OPTS` variable. Metrics are available under local endpoint http://localhost:9404/metrics. |
| CASSANDRA_CGROUP_MEMORY_LIMIT | Specifies if heap size should be limited by cgroup constraints <br><br> If set to `true`, this variable add `-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:MaxRAMFraction=2` to `$JVM_OPTS` variable. This will restrict maximum heap size to cgroup limit. |

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description** |
|:---------|:----------------|
| /var/lib/cassandra | All Cassandra files are installed here. |
