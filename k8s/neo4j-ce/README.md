# Overview

Neo4j Community Edition 4.x is an open source graph database management system,
written in Java. It provides a web dashboard for managing data and users. You
can access its service by using an HTTP REST API or the Bolt binary protocol.

The Community Edition (CE) of Neo4j is not production-ready. It is ideal for
learning or testing environments.

This solution does not support clustering, hot backup/restore, sharding data, or
advanced indexes.

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

![Architecture diagram](resources/neo4j-ce-k8s-app-architecture.png)

By default, Neo4j CE is exposed internally through a ClusterIP Service on
two ports:

* `7474`, for the Neo4j Browser and API
* `7687`, for the Bolt Service

A StatefulSet object is used to manage the Neo4j workloads. Because Neo4j CE
does not support scaling, you should have a maximum of 1 replica as part of
a StatefulSet.

The Neo4j Browser connects to the Bolt service through the port `7687`. If
you want to set access credentials, use the `NEO4J_AUTH` environment
variables.

You can set up all Neo4j configurations by using environment variables. For
more information about using environment variables to configure Neo4j, visit
the
[official Neo4j documentation](https://neo4j.com/docs/operations-manual/current/docker/configuration/).

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! To install this Neo4j Community Edition app
to a Google Kubernetes Engine (GKE) cluster in Google Cloud Marketplace, follow
these 
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/neo4j-ce).

## Command-line instructions

### Prerequisites

#### Setting up command-line tools

You'll need the following tools in your development environment:

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Creating a Google Kubernetes Engine (GKE) cluster

Create a new cluster from the command line:

```shell
export CLUSTER=neo4j-ce-cluster
export ZONE=us-west1-a

gcloud container clusters create "${CLUSTER}" --zone "${ZONE}"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}"
```

#### Cloning this repo

Clone this repo, as well as its associated tools repo:

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Installing the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following
command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.

The
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community defines the Application resource. You can find the source code at
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Installing the app

Navigate to the `neo4j-ce` directory:

```shell
cd click-to-deploy/k8s/neo4j-ce
```

#### Configuring the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=neo4j-ce-1
export NAMESPACE=default
```

Configure the container image:

```shell
TAG=4.0
export IMAGE_REGISTRY="marketplace.gcr.io/google"
export IMAGE_NEO4J_CE="${IMAGE_REGISTRY}/neo4j4"
```

For persistent disk provisioning of the Neo4j CE servers, you must:

 * Specify the StorageClass name. For persistent disk provisioning of a Neo4j
   server, you should use the name of your existing StorageClass.
 * Specify the size of the persistent disk. The default disk size is `10Gi`.

> Note: We recommend that you use storage of type `ssd` for Neo4j CE, because
> it uses local disk to store and retrieve keys and values.

If you want to create a StorageClass for dynamic provisioning of SSD persistent
volumes, refer to
[Using SSD persistent disks](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/ssd-pd)
for detailed instructions.

```shell
export NEO4J_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export PERSISTENT_DISK_SIZE="10Gi"
```

Set or generate the passwords:

```shell
# Set password. Use your own passwords
export NEO4J_PASSWORD="root_password"
```

#### Creating namespace in your Kubernetes cluster

If you use a different namespace than the `default`, create a new namespace by
running the following command:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Expanding the manifest template

To expand the template, use `helm template`. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template chart/neo4j-ce \
  --name "${APP_INSTANCE_NAME}" \
  --namespace "${NAMESPACE}" \
  --set "neo4j.image.repo=${IMAGE_NEO4J_CE}" \
  --set "neo4j.image.tag=${TAG}" \
  --set "neo4j.persistence.storageClass=${NEO4J_STORAGE_CLASS}" \
  --set "neo4j.persistence.size=${PERSISTENT_DISK_SIZE}" \
  --set "neo4j.password=${NEO4J_PASSWORD}" \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Applying the manifest to your Kubernetes cluster

To apply the manifest to your Kubernetes cluster, use `kubectl`:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### Viewing the app in the Google Cloud Console

To get the Cloud Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

### Accessing Neo4j (internally)

If you want to connect to Neo4j CE, without exposing it to public access, you
can use any of the following methods:

* The `curl` command line tool, or any other HTTP Client, on port `7474`.
* The Neo4j browser, on port `7474`.
* Cypher Shell, or another Bolt client, on port `7687`.

#### Interacting with the Neo4j Browser by using port-forwarding

To access the Neo4j Browser, you must forward two ports: `7474` and `7687`.

First, forward the Neo4j Bolt port to your machine:

```shell
kubectl port-forward svc/${APP_INSTANCE_NAME}-neo4j-svc --namespace "${NAMESPACE}" 7687:7687
```

After that, forward the Neo4j HTTP port to your machine:

```shell
kubectl port-forward svc/${APP_INSTANCE_NAME}-neo4j-svc --namespace "${NAMESPACE}" 7474:7474
```

Open a browser window and navigate to
[http://localhost:7474/browser](http://localhost:7474/browser). To sign in,
use your credentials.

#### Creating and retrieving items by using Cypher Shell

To create and retrieve items by using Cypher Shell, you must identify if
the Neo4j pod is ready:

```shell
kubectl get pods -o wide -l app.kubernetes.io/name=${APP_INSTANCE_NAME} --namespace "${NAMESPACE}"
```

You can then create a node in the Neo4j database:

```shell
# Create a node via cypher-shell
kubectl exec -it "${APP_INSTANCE_NAME}-0" --namespace "${NAMESPACE}" -- cypher-shell -u "neo4j" -p "${NEO4J_PASSWORD}" -d "neo4j" 'CREATE(n:Person { name: "John Doe"})'
```

This will return something like:

```
0 rows available after 172 ms, consumed after another 0 ms
Added 1 nodes, Set 1 properties, Added 1 labels
```

To query data in the Neo4j database, run the following command:

```shell
# Query a database via cypher-shell
kubectl exec -it "${APP_INSTANCE_NAME}-0" --namespace "${NAMESPACE}" -- cypher-shell -u "neo4j" -p "${NEO4J_PASSWORD}" -d "neo4j" 'MATCH(n:Person) RETURN n'
```

This will return something like:

```shell
+------------------------------+
| n                            |
+------------------------------+
| (:Person {name: "John Doe"}) |
+------------------------------+

1 row available after 223 ms, consumed after another 7 ms
```

#### Creating and retrieving items by using an HTTP API

If you want to create and retrieve items by using an HTTP API, port-forwarding
must be enabled for port `7474`.

Create a node in the Neo4j database:

```shell
# Create a node via API
curl -X POST -u 'neo4j:${NEO4J_PASSWORD}' -d '{"statements":[{"statement":"CREATE(n:Person { name:\"Jane Doe\"} )"}]}' -H 'Content-Type:application/json' 'http://localhost:7474/db/neo4j/tx'
```

This will return something like:

```json
{"results":[{"columns":[],"data":[]}],"errors":[],"commit":"http://localhost:7474/db/neo4j/tx/1/commit","transaction":{"expires":"Sun, 22 Mar 2020 20:22:43 GMT"}}
```

After creating your node, commit your transaction. To confirm the transation,
use the URL returned by the previous request, inside a `commit` parameter:

```shell
# Commit a transaction via API
curl -X POST -u 'neo4j:${NEO4J_PASSWORD}' -H 'Content-Type:application/json' 'http://localhost:7474/db/neo4j/tx/1/commit'

```

This will return something like:

```json
{"results":[],"errors":[],"commit":"http://localhost:7474/db/neo4j/tx/2/commit"}
```

To query data in the Neo4j database, run the following command:

```shell
# Query a database via API
curl -X POST -u 'neo4j:${NEO4J_PASSWORD}' -d '{"statements":[{"statement":"MATCH (n:Person) RETURN n"}]}' -H 'Content-Type:application/json' 'http://localhost:7474/db/neo4j/tx'
```

This will return something like:

```json
{"results":[{"columns":["n"],"data":[{"row":[{"name":"John Doe"}],"meta":[{"id":0,"type":"node","deleted":false}]},{"row":[{"name":"Jane Doe"}],"meta":[{"id":2,"type":"node","deleted":false}]}]}],"errors":[],"commit":"http://localhost:7474/db/neo4j/tx/4/commit","transaction":{"expires":"Sun, 22 Mar 2020 20:31:13 GMT"}}
```

# Backing up and restoring

Neo4j CE does not support online backups, so if you want to back up and restore
your database, you must first take it offline.

## Backing up Neo4j data to your local workstation

To back up all of the data in your working directory, run the following
commands:

```shell
# Scale to 0 the number of replicas
kubectl scale statefulsets "${APP_INSTANCE_NAME}" --namespace "${NAMESPACE}" --replicas 0

# Apply the backup pod, which will mount the /data directory
kubectl apply --namespace "${NAMESPACE}" -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: backup
spec:
  volumes:
    - name: backup-storage
      persistentVolumeClaim:
        claimName: ${APP_INSTANCE_NAME}-neo4j-pvc
  containers:
    - name: backup-container
      image: marketplace.gcr.io/google/debian9
      volumeMounts:
        - mountPath: "/data"
          name: backup-storage
EOF

# Set the timestamp
export LOCAL_TS=$(echo '('`date +"%Y%m%d%H%M%S"` ')' | bc)

# Append the timestamp to file where the backup will be stored
export LOCAL_FILE="${LOCAL_TS}-neo4j-data.tar.gz"

# Back up all data
kubectl exec -ti backup -- tar cvfz backup.tar.gz /data

# Copy the backup loclly
kubectl cp "${NAMESPACE}/backup:backup.tar.gz" "${LOCAL_FILE}"

# Deletes the backup pod
kubectl delete pod/backup

# Enable Neo4j service again
kubectl scale statefulsets "${APP_INSTANCE_NAME}" --namespace "${NAMESPACE}" --replicas 1
```

## Restoring Neo4j data from your local workstation

To restore Neo4j data from your local workstation, you must specify the name
of the backup file name in the `LOCAL_FILE` variable.

```shell
# Scales to 0 pods your Neo4j StatefulSet
kubectl scale statefulsets "${APP_INSTANCE_NAME}" --namespace "${NAMESPACE}" --replicas 0

# Applies the restore pod, which will mount the /data directory
kubectl apply --namespace "${NAMESPACE}" -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: restore
spec:
  volumes:
    - name: backup-storage
      persistentVolumeClaim:
        claimName: ${APP_INSTANCE_NAME}-neo4j-pvc
  containers:
    - name: backup-container
      image: marketplace.gcr.io/google/debian9
      volumeMounts:
        - mountPath: "/data"
          name: backup-storage
EOF

# Here you should define your backup file
export LOCAL_FILE="define-here-your-backup-neo4j-data.tar.gz"

# Copies the backup file to the pod
kubectl cp "${LOCAL_FILE}" "${NAMESPACE}/restore:/backup.tar.gz"

# Restore the data
kubectl exec -ti restore -- tar -C / -zxvf /backup.tar.gz

# Deletes the restore pod
kubectl delete pod/restore

# Restores the Neo4j service
kubectl scale statefulsets "${APP_INSTANCE_NAME}" --namespace "${NAMESPACE}" --replicas 1
```

### Scaling

Neo4j CE does not run as part of a cluster. If you want to run Neo4j as part
of a cluster, you need the Enterprise Edition of Neo4J.

### Upgrading

The Neo4j CE StatefulSet is configured to automatically roll out updates. To
start an update, patch the StatefulSet with a new image reference:

```shell
kubectl set image statefulset ${APP_INSTANCE_NAME}-neo4j-ce --namespace ${NAMESPACE} \
  "neo4j-ce=[NEW_IMAGE_REFERENCE]"
```

where `[NEW_IMAGE_REFERENCE]` is the Docker image reference of the new image
that you want to use.

To check the status of Pods in the StatefulSet, and the progress of the new
image, run the following command:

```shell
kubectl get pods --selector app.kubernetes.io/name=${APP_INSTANCE_NAME} \
  --namespace ${NAMESPACE}
```

# Uninstalling the app

## Uninstalling the app by using the Google Cloud Console

1.  In the Cloud Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

2.  From the list of apps, click **Neo4j Community Edition**.

3.  On the **Application Details** page, click **Delete**.

## Uninstalling the app by using the command line

### Preparing your environment

Specify your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=neo4j-ce-1
export NAMESPACE=default
```

### Deleting the resources

> **NOTE:** We recommend that you use a `kubectl` version that is the same as
> the version of your cluster. Using the same version for `kubectl` and the
> cluster helps to avoid unforeseen issues.

#### Deleting the deployment by using the generated manifest file

Run `kubectl` on the expanded manifest file:

> **WARNING:** This also deletes your `PersistentVolumeClaims` for Neo4j CE,
> which destroys all of your Neo4j CE data.

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace ${NAMESPACE}
```

#### Deleting the deployment by deleting the Application resource

If you don't have the expanded manifest file, you can delete the resources by
using types and a label:

```shell
kubectl delete application,statefulset,secret,service \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

Deleting the `Application` resource deletes all of your deployment's resources,
except for `PersistentVolumeClaim`. To remove the `PersistentVolumeClaim`s
with their attached persistent disks, run the following `kubectl` command:

```shell
kubectl delete persistentvolumeclaims \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

### Delete the GKE cluster

If you don't need the deployed app or the GKE cluster, you can delete the
cluster by running the following command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```
