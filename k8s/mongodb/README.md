# Overview

MongoDB is a NoSQL document-oriented database that stores JSON-like documents with dynamic schemas,
simplifying the integration of data in content-driven applications.

[Learn more](https://www.mongodb.com).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this MongoDB app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/mongodb).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [MongoDB shell - optional](https://docs.mongodb.com/manual/administration/install-on-linux/)

To install optional mongodb-org-shell package please fallow up steps
described on the [MongoDB site](https://docs.mongodb.com/manual/administration/install-on-linux/)
for your OS.

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=mongodb-cluster
export ZONE=us-central1-b

gcloud container clusters create "$CLUSTER" --zone "$ZONE" --machine-type n1-standard-2 --num-nodes 3
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo.

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following command:

```shell
kubectl apply -f click-to-deploy/k8s/vendor/marketplace-tools/crd/*
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `mongodb` directory:

```shell
cd click-to-deploy/k8s/mongodb
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=mongo-1
export NAMESPACE=default
```

Set the number of replicas for MongoDB:

```shell
# Setting a single node in MongoDB cluster means single point of failure.
# For production environments, consider at least 3 replicas.
export REPLICAS=3
```

Configure the container images:

```shell
TAG=4.0.1
export IMAGE_MONGODB="marketplace.gcr.io/google/mongodb:${TAG}"
export IMAGE_SIDECAR="marketplace.gcr.io/google/mongodb-sidecar:${TAG}"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images,
until you are ready to upgrade. To get the digest for the image, use the
following script:

```shell
for i in "IMAGE_MONGODB"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```

```shell
for i in "IMAGE_SIDECAR"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```


#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "$NAMESPACE"
```

#### Expand the manifest template

Use `envsubst` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_MONGO $IMAGE_SIDECAR $REPLICAS' \
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

To view your app, open the URL in your browser.

### Check the status of the MongoDB cluster

If your deployment is successful, you can check status of your MongoDB
cluster.

On one of the MongoDB containers, run the `rs.status()` command.

```shell
kubectl exec "${APP_INSTANCE_NAME}-mongo-0" --namespace "${NAMESPACE}" -c mongo -- mongo --eval "rs.status()"
```
The command will give a output similar to the below:

```shell
MongoDB shell version v4.0.1
connecting to: mongodb://127.0.0.1:27017
MongoDB server version: 4.0.1
{
  "set" : "rs0",
  "date" : ISODate("2018-09-18T11:13:03.527Z"),
  "myState" : 1,
  "term" : NumberLong(1),
  "syncingTo" : "",
  "syncSourceHost" : "",
  "syncSourceId" : -1,
  "heartbeatIntervalMillis" : NumberLong(2000),
  "optimes" : {
    "lastCommittedOpTime" : {
      "ts" : Timestamp(1537269177, 1),
      "t" : NumberLong(1)
    },
    "readConcernMajorityOpTime" : {
      "ts" : Timestamp(1537269177, 1),
      "t" : NumberLong(1)
    },
    "appliedOpTime" : {
      "ts" : Timestamp(1537269177, 1),
      "t" : NumberLong(1)
    },
    "durableOpTime" : {
      "ts" : Timestamp(1537269177, 1),
      "t" : NumberLong(1)
    }
  },
  {
  ...
  ...
  ...
  },
  "ok" : 1,
  "operationTime" : Timestamp(1537269177, 1),
  "$clusterTime" : {
    "clusterTime" : Timestamp(1537269177, 1),
    "signature" : {
      "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
      "keyId" : NumberLong(0)
    }
  }

```

### Connecting to MongoDB (internal access)

If you have installed mongodb-org-shell package, you can connect to the MongoDB service without exposing your cluster
for public access, using the following options:

* Use port forwarding to access the service, run the following command:

     ```shell
     kubectl port-forward "${APP_INSTANCE_NAME}-mongo-0" 27017:27017 --namespace "${NAMESPACE}"
     ```

    Then, in your main terminal, start `mongo shell`:

    ```shell
    mongo
    ```

    In the response, you see the MongoDB welcome message:

    ```shell
    To enable free monitoring, run the following command: db.enableFreeMonitoring()
    To permanently disable this reminder, run the following command: db.disableFreeMonitoring()
    ---

    rs0:PRIMARY>
    ```

# Scaling the MongoDB app

### Scaling the cluster up

By default, the MongoDB app is deployed using 3 replicas. To change the number of replicas, use the following command:

```
kubectl scale statefulsets "$APP_INSTANCE_NAME-mongo" \
  --namespace "$NAMESPACE" --replicas=[NEW_REPLICAS]
```

where `[NEW_REPLICAS]` is the new amount of the replicas.

### Scaling the cluster down

To scale down run the following command:

```shell
  kubectl scale statefulsets "$APP_INSTANCE_NAME-mongo" -n "$NAMESPACE" --replicas=[NEW_REPLICAS]
```
Please remember to delete unused POD's storage.

For more information about scaling StatefulSets, see the
[Kubernetes documentation](https://kubernetes.io/docs/tasks/run-application/scale-stateful-set/#kubectl-scale).

# Backup and Restore

### Backing up your data

Back up your MongoDB data.

To backup your MongoDB databases just run the backup script [`scripts/backup.sh`](scripts/backup.sh).

```shell
 scripts/backup.sh -n "$NAMESPACE" -c mongo -p "$APP_INSTANCE_NAME-mongo" -a backup-mongo
```

After you run the script, the backup-mongo.tgz` file contains
the backup will be on your local machine.

### Restoring

In the directory that contains your backup files, run the restore script [`scripts/backup.sh`](scripts/backup.sh).

```shell
 scripts/restore.sh -n "$NAMESPACE" -c mongo -p "$APP_INSTANCE_NAME-mongo" -a <backup file name>
```

# Updating the app

Before updating, we recommend backing up your data.
Please visit MongoDB release notes page and read manual "Upgrade a Replica Set"
for your version.
[MongoDB release notes](https://docs.mongodb.com/manual/release-notes).

## Update the cluster nodes

### Patch the StatefulSet with the new image

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=mongodb-1
export NAMESPACE=default
```

Assign the new image to your StatefulSet definition:

```shell
IMAGE_MONGODB=[NEW_IMAGE_REFERENCE]

kubectl set image statefulset "${APP_INSTANCE_NAME}-mongo" \
  --namespace "${NAMESPACE}" "mongodb=${IMAGE_MONGODB}"
```

After this operation, the StatefulSet has a new image configured for the
containers. However, because of the OnDelete update strategy on the
StatefulSet, the pods will not automatically restart, please falow [MongoDB procedure](https://docs.mongodb.com/manual/release-notes).


## Using the Google Cloud Platform Console

1. In the GCP Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of applications, click **mongodb-1**.

1. On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=mongodb-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend to use a kubectl version that is the same as the version of your cluster. Using the same versions of kubectl and the cluster helps avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

Otherwise, delete the resources using types and a label:

```shell
kubectl delete application,statefulset,service \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete the persistent volumes of your installation

By design, the removal of StatefulSets in Kubernetes does not remove
PersistentVolumeClaims that were attached to their Pods. This prevents your
installations from accidentally deleting stateful data.

To remove the PersistentVolumeClaims with their attached persistent disks, run
the following `kubectl` commands:

```shell
for pv in $(kubectl get pvc --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME \
  --output jsonpath='{.items[*].spec.volumeName}');
do
  kubectl delete pv/$pv --namespace $NAMESPACE
done

kubectl delete persistentvolumeclaims \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete the GKE cluster

Optionally, if you don't need the deployed application or the GKE cluster,
delete the cluster using this command:

```
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```
