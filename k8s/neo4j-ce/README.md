# Overview

Neo4j Community Edition 4.x is an open source graph database management system written in Java.
It provides a web dashboard for managing data and users. Service is accessible through HTTP REST API or binary bolt protocol.

The Community Edition is perfect for learning or testing environments, not production ready.

Solution does not support clustering, hot backup/restore, sharding data or advanced indexes.

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

## Architecture

![Architecture diagram](resources/neo4j-ce-k8s-app-architecture.png)

By default, Neo4j CE is exposed internally using a ClusterIP Service on two ports, as follows:

* `7474` - for Neo4j Browser and API
* `7687` - for Bolt Service

A StatefulSet object is used to manage the Neo4j workloads. As per Community Edition is not supposed to scale, you should have at maximum 1 replicas as a part of a StatefulSet.

The Neo4j Browser connects to Bolt service through the port `7697`. Credentials can be set via `NEO4J_AUTH` environment variables.

All Neo4j configurations can be set using environment variables. For more information, [check the documentation page](https://neo4j.com/docs/operations-manual/current/docker/configuration/).

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Neo4j Community Edition app to a Google
Kubernetes Engine cluster in Google Cloud Marketplace by following these
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/neo4j-ce).

## Command line instructions

### Prerequisites

#### Set up command-line tools

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

#### Create a Google Kubernetes Engine (GKE) cluster

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

#### Clone this repo

Clone this repo, as well as the associated tools repo:

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following
command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.

The Application resource is defined by the [Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps) community. The source code
can be found on [github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the app

Navigate to the `neo4j-ce` directory:

```shell
cd click-to-deploy/k8s/neo4j-ce
```

#### Configure the app with environment variables

Choose an instance name and [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) for the app. In most cases, you can
use the `default` namespace.

```shell
export APP_INSTANCE_NAME=neo4j-ce-1
export NAMESPACE=default
```

Configure the container image:

```shell
TAG=4.0
export IMAGE_REGISTRY="marketplace.gcr.io/google"
export IMAGE_NEO4J_CE="${IMAGE_REGISTRY}/neo4j-ce4"
```

For the persistent disk provisioning of the Neo4j Community Edition servers, you will need to:

 * Set the StorageClass name. You should select your existing StorageClass name for persistent disk provisioning for Neo4j server.
 * Set the persistent disk's size. The default disk size is "10Gi".
> Note: "ssd" type storage is recommended for Neo4j Community Edition, as it uses local disk
> to store and retrieve keys and values.
> To create a StorageClass for dynamic provisioning of SSD persistent volumes, check out [this documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/ssd-pd) for more detailed instructions.
```shell
export NEO4J_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export PERSISTENT_DISK_SIZE="10Gi"
```

Set or generate the passwords:

```shell
# Set password. Use your own passwords
export NEO4J_PASSWORD="root_password"
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to
create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/neo4j-ce \
  --name "${APP_INSTANCE_NAME}" \
  --namespace "${NAMESPACE}" \
  --set "neo4j.image.repo=${IMAGE_NEO4J_CE}" \
  --set "neo4j.image.tag=${TAG}" \
  --set "neo4j.persistence.storageClass=${STORAGE_CLASS}" \
  --set "neo4j.persistence.size=${PERSISTENT_DISK_SIZE}" \
  --set "neo4j.password=${NEO4J_PASSWORD}" \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

### Access Neo4j (internally)

You can connect to Neo4j Community Edition without exposing it to public access by two ways:

* on port `7474` - via `curl` command line tool or any other HTTP Client.
* on port `7474` - via Neo4j browser.
* on port `7687` - via cypher-shell or other Bolt client.


#### Interact with Neo4j Browser using port-forwarding

In order to access Neo4j Browser, you will be required to forward two ports: `7474` and `7687`.

First, in one different terminal, forward the Neo4j Bolt port to your machine by using the
following command:
```shell
kubectl port-forward svc/${APP_INSTANCE_NAME}-neo4j-svc --namespace "${NAMESPACE}" 7687:7687
```

Then, forward the Neo4j HTTP port to your machine using the command:
```shell
kubectl port-forward svc/${APP_INSTANCE_NAME}-neo4j-svc --namespace "${NAMESPACE}" 7474:7474
```

Lastly, in a browser window navigate to: [http://localhost:7474/browser](http://localhost:7474/browser) . And use your credentials to sign-in.

#### Create and retrieve items via cypher-shell

To do this, please identify if Neo4j's pod is ready using the following command:

```shell
kubectl get pods -o wide -l app.kubernetes.io/name=${APP_INSTANCE_NAME} --namespace "${NAMESPACE}"
```

You can then create a node in Neo4j database:

```shell
# Create a node via cypher-shell
kubectl exec -it "${APP_INSTANCE_NAME}-0" --namespace "${NAMESPACE}" -- cypher-shell -u "neo4j" -p "${NEO4J_PASSWORD}" -d "neo4j" 'CREATE(n:Person { name: "John Doe"})'
```

The return will be similar to the following:
```
0 rows available after 172 ms, consumed after another 0 ms
Added 1 nodes, Set 1 properties, Added 1 labels
```

In order to query data in Neo4j database, use:

```shell
# Query a database via cypher-shell
kubectl exec -it "${APP_INSTANCE_NAME}-0" --namespace "${NAMESPACE}" -- cypher-shell -u "neo4j" -p "${NEO4J_PASSWORD}" -d "neo4j" 'MATCH(n:Person) RETURN n'
```

The return should be similar to the following:

```shell
+------------------------------+
| n                            |
+------------------------------+
| (:Person {name: "John Doe"}) |
+------------------------------+

1 row available after 223 ms, consumed after another 7 ms
```

#### Create and retrieve items via HTTP API

First of all, make sure that port-forwarding of port `7474` is enabled.
Then, You can create a node in Neo4j database:

```shell
# Create a node via API
curl -X POST -u 'neo4j:${NEO4J_PASSWORD}' -d '{"statements":[{"statement":"CREATE(n:Person { name:\"Jane Doe\"} )"}]}' -H 'Content-Type:application/json' 'http://localhost:7474/db/neo4j/tx'
```

The return will be similar to the following:
```json
{"results":[{"columns":[],"data":[]}],"errors":[],"commit":"http://localhost:7474/db/neo4j/tx/1/commit","transaction":{"expires":"Sun, 22 Mar 2020 20:22:43 GMT"}}
```

Now you should commit your transaction. Use the URL returned in previous request inside `commit` parameter to confirm it:

```shell
# Commit a transaction via API
curl -X POST -u 'neo4j:${NEO4J_PASSWORD}' -H 'Content-Type:application/json' 'http://localhost:7474/db/neo4j/tx/1/commit'

```

The results should be similar to the following:

```json
{"results":[],"errors":[],"commit":"http://localhost:7474/db/neo4j/tx/2/commit"}
```

In order to query data in Neo4j database, use:

```shell
# Query a database via API
curl -X POST -u 'neo4j:${NEO4J_PASSWORD}' -d '{"statements":[{"statement":"MATCH (n:Person) RETURN n"}]}' -H 'Content-Type:application/json' 'http://localhost:7474/db/neo4j/tx'
```

The return should be similar to the following:

```json
{"results":[{"columns":["n"],"data":[{"row":[{"name":"John Doe"}],"meta":[{"id":0,"type":"node","deleted":false}]},{"row":[{"name":"Jane Doe"}],"meta":[{"id":2,"type":"node","deleted":false}]}]}],"errors":[],"commit":"http://localhost:7474/db/neo4j/tx/4/commit","transaction":{"expires":"Sun, 22 Mar 2020 20:31:13 GMT"}}
```

# Backup and Restore

Neo4j Community Edition does not support online backups, so in order to backup and restore your database, you should take it down.

## Backup Neo4j data to your local workstation

The commands below will back up all your data in your working directory:

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

## Restore Magento data on a running Magento instance

In order to restore Neo4j data, you must specify the backup file name in `LOCAL_FILE` variable.

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

Neo4j Community Edition does not run in a cluster mode. For more information, check Enterprise Version.

### Upgrading

The Neo4j Community Edition StatefulSet is configured to roll out updates automatically.
To start an update, patch the StatefulSet with a new image reference:

```shell
kubectl set image statefulset ${APP_INSTANCE_NAME}-neo4j-ce --namespace ${NAMESPACE} \
  "neo4j-ce=[NEW_IMAGE_REFERENCE]"
```
Where [NEW_IMAGE_REFERENCE] is the Docker image reference of the new image that you want to use.

To check the status of Pods in the StatefulSet, and the progress of
the new image, run the following command:

```shell
kubectl get pods --selector app.kubernetes.io/name=${APP_INSTANCE_NAME} \
  --namespace ${NAMESPACE}
```

# Uninstall the app

## Using the Google Cloud Console

1.  In the Cloud Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

2.  From the list of apps, click **Neo4j Community Edition**.

3.  On the Application Details page, click **Delete**.

## Using the command-line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=neo4j-ce-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend using a `kubectl` version that is the same as the
> version of your cluster. Using the same version for `kubectl` and the cluster
> helps to avoid unforeseen issues.

#### Delete the deployment with the generated manifest file

Run `kubectl` on the expanded manifest file:
> **WARNING:** This will also delete your `PersistentVolumeClaims`
> for Neo4j Community Edition, which means that you will lose all of your Neo4j Community Edition data.

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace ${NAMESPACE}
```

#### Delete the deployment by deleting the application resource

If you don't have the expanded manifest file, delete the resources by using types
and a label:

```shell
kubectl delete application,statefulset,secret,service \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

Deleting the `Application` resource will delete all of your deployment's resources,
except for `PersistentVolumeClaim`. To remove the PersistentVolumeClaims with their
attached persistent disks, run the following `kubectl` command:

```shell
kubectl delete persistentvolumeclaims \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

### Delete the GKE cluster

Optionally, if you don't need the deployed app or the GKE cluster,
delete the cluster by using this command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```
