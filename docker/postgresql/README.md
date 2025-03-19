postgresql-docker
============

Dockerfile source for postgresql [docker](https://docker.io) image.

# Upstream
This source repo was originally copied from:
https://github.com/docker-library/postgres

# Disclaimer
This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of PostgreSQL 13.x.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/details/google/postgresql13).

Pull command (first install [gcloud](https://cloud.google.com/sdk/downloads)):

```shell
gcloud docker -- pull marketplace.gcr.io/google/postgresql13
```

Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/postgresql-docker/tree/master/13).

# <a name="table-of-contents"></a>Table of Contents
* [Using Kubernetes](#using-kubernetes)
  * [Run a PostgreSQL server](#run-a-postgresql-server-kubernetes)
    * [Start a PostgreSQL instance](#start-a-postgresql-instance-kubernetes)
    * [Use a persistent data volume](#use-a-persistent-data-volume-kubernetes)
  * [Postgres CLI](#postgres-cli-kubernetes)
    * [Connect to a running PostgreSQL container](#connect-to-a-running-postgresql-container-kubernetes)
    * [Connect to a remote PostgreSQL server](#connect-to-a-remote-postgresql-server-kubernetes)
  * [Maintenance](#maintenance-kubernetes)
    * [Creating database dumps](#creating-database-dumps-kubernetes)
* [Using Docker](#using-docker)
  * [Run a PostgreSQL server](#run-a-postgresql-server-docker)
    * [Start a PostgreSQL instance](#start-a-postgresql-instance-docker)
    * [Use a persistent data volume](#use-a-persistent-data-volume-docker)
  * [Postgres CLI](#postgres-cli-docker)
    * [Connect to a running PostgreSQL container](#connect-to-a-running-postgresql-container-docker)
    * [Connect to a remote PostgreSQL server](#connect-to-a-remote-postgresql-server-docker)
  * [Maintenance](#maintenance-docker)
    * [Creating database dumps](#creating-database-dumps-docker)
* [References](#references)
  * [Ports](#references-ports)
  * [Environment Variables](#references-environment-variables)
  * [Volumes](#references-volumes)

# <a name="using-kubernetes"></a>Using Kubernetes

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Kubernetes environment.

## <a name="run-a-postgresql-server-kubernetes"></a>Run a PostgreSQL server

This section describes how to spin up a PostgreSQL service using this image.

### <a name="start-a-postgresql-instance-kubernetes"></a>Start a PostgreSQL instance

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-postgres
  labels:
    name: some-postgres
spec:
  containers:
    - image: marketplace.gcr.io/google/postgresql13
      name: postgres
      env:
        - name: "POSTGRES_PASSWORD"
          value: "example-password"
```

Run the following to expose the port.
Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-postgres --name some-postgres-5432 \
  --type LoadBalancer --port 5432 --protocol TCP
```

For information about how to retain your database across restarts, see [Use a persistent data volume](#use-a-persistent-data-volume-kubernetes).

### <a name="use-a-persistent-data-volume-kubernetes"></a>Use a persistent data volume

We can store PostgreSQL data on a persistent volume. This way the database remains intact across restarts.

Copy the following content to `pod.yaml` file, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-postgres
  labels:
    name: some-postgres
spec:
  containers:
    - image: marketplace.gcr.io/google/postgresql13
      name: postgres
      env:
        - name: "POSTGRES_PASSWORD"
          value: "example-password"
      volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
          subPath: data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: data
---
# Request a persistent volume from the cluster using a Persistent Volume Claim.
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: data
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
kubectl expose pod some-postgres --name some-postgres-5432 \
  --type LoadBalancer --port 5432 --protocol TCP
```

## <a name="postgres-cli-kubernetes"></a>Postgres CLI

This section describes how to use this image as a PostgreSQL client.

### <a name="connect-to-a-running-postgresql-container-kubernetes"></a>Connect to a running PostgreSQL container

You can run a PostgreSQL client directly within the container.

```shell
kubectl exec -it some-postgres -- psql --username postgres
```

Note: No password is required when connecting from inside the same container.

### <a name="connect-to-a-remote-postgresql-server-kubernetes"></a>Connect to a remote PostgreSQL server

Assume that we have a PostgreSQL server running at `some-host` and we want to log on to `some-db` database as `postgres` user. Run the following command. You will need to enter the password even though there might be no visible passowrd prompt; this is due to limitations of `kubectl exec`.

```shell
kubectl run \
  some-postgres-client \
  --image marketplace.gcr.io/google/postgresql13 \
  --rm --attach --restart=Never \
  -it \
  -- sh -c 'exec psql --host some-host --dbname some-db --username postgres --password'
```

## <a name="maintenance-kubernetes"></a>Maintenance

### <a name="creating-database-dumps-kubernetes"></a>Creating database dumps

All databases can be dumped into a `/some/path/all-databases.sql` file on the host using the following command.

```shell
kubectl exec -it some-postgres -- sh -c 'exec pg_dumpall --username postgres' > /some/path/all-databases.sql
```

# <a name="using-docker"></a>Using Docker

Consult [Marketplace container documentation](https://cloud.google.com/marketplace/docs/container-images)
for additional information about setting up your Docker environment.

## <a name="run-a-postgresql-server-docker"></a>Run a PostgreSQL server

This section describes how to spin up a PostgreSQL service using this image.

### <a name="start-a-postgresql-instance-docker"></a>Start a PostgreSQL instance

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  postgres:
    container_name: some-postgres
    image: marketplace.gcr.io/google/postgresql13
    environment:
      "POSTGRES_PASSWORD": "example-password"
    ports:
      - '5432:5432'
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-postgres \
  -e "POSTGRES_PASSWORD=example-password" \
  -p 5432:5432 \
  -d \
  marketplace.gcr.io/google/postgresql13
```

The PostgreSQL server is accessible on port 5432.

For information about how to retain your database across restarts, see [Use a persistent data volume](#use-a-persistent-data-volume-docker).

### <a name="use-a-persistent-data-volume-docker"></a>Use a persistent data volume

We can store PostgreSQL data on a persistent volume. This way the database remains intact across restarts. Assume that `/my/persistent/dir/postgres` is the persistent directory on the host.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  postgres:
    container_name: some-postgres
    image: marketplace.gcr.io/google/postgresql13
    environment:
      "POSTGRES_PASSWORD": "example-password"
    ports:
      - '5432:5432'
    volumes:
      - /my/persistent/dir/postgres:/var/lib/postgresql/data
```

Or you can use `docker run` directly:

```shell
docker run \
  --name some-postgres \
  -e "POSTGRES_PASSWORD=example-password" \
  -p 5432:5432 \
  -v /my/persistent/dir/postgres:/var/lib/postgresql/data \
  -d \
  marketplace.gcr.io/google/postgresql13
```

## <a name="postgres-cli-docker"></a>Postgres CLI

This section describes how to use this image as a PostgreSQL client.

### <a name="connect-to-a-running-postgresql-container-docker"></a>Connect to a running PostgreSQL container

You can run a PostgreSQL client directly within the container.

```shell
docker exec -it some-postgres psql --username postgres
```

Note: No password is required when connecting from inside the same container.

### <a name="connect-to-a-remote-postgresql-server-docker"></a>Connect to a remote PostgreSQL server

Assume that we have a PostgreSQL server running at `some-host` and we want to log on to `some-db` database as `postgres` user. Run the following command.

## <a name="maintenance-docker"></a>Maintenance

### <a name="creating-database-dumps-docker"></a>Creating database dumps

All databases can be dumped into a `/some/path/all-databases.sql` file on the host using the following command.

```shell
docker exec -it some-postgres sh -c 'exec pg_dumpall --username postgres' > /some/path/all-databases.sql
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image.

| **Port** | **Description** |
|:---------|:----------------|
| TCP 5432 | Standard PostgreSQL port. |

## <a name="references-environment-variables"></a>Environment Variables

These are the environment variables understood by the container image.

| **Variable** | **Description** |
|:-------------|:----------------|
| POSTGRES_PASSWORD | The password for the superuser. Also see `POSTGRES_USER` environment variable. |
| POSTGRES_USER | Optionally specifies the name of the superuser. Defaults to `postgres`. |
| PGDATA | Optionally specifies the directory location of the database files. Defaults to `/var/lib/postgresql/data`. |
| POSTGRES_DB | Optionally specifies the name of the default database to be created when the image is first started. Defaults to the value of `POSTGRES_USER`. |
| POSTGRES_INITDB_ARGS | Optionally specifies arguments to send to `postgres initdb`. For example. `--data-checksums --encoding=UTF8`. |
| POSTGRES_INITDB_WALDIR | Optionally specifies a location for the Postgres transaction log. Defaults to a subdirectory of the main Postgres data folder (`PGDATA`). |

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image.

| **Path** | **Description** |
|:---------|:----------------|
| /var/lib/postgresql/data | Stores the database files. This is the default which can altered by `PGDATA` environment variable. |
