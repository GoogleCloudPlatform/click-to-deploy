# Overview

OrientDB is an open source NoSQL database management system written in Java.

This solution supports both [OrientDB 2.2.x](http://orientdb.com/docs/2.2.x/) and [OrientDB 3.0.x](http://orientdb.com/docs/3.0.x/) track versions.

For more information, visit the OrientDB [official website](https://orientdb.com//).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

![Architecture diagram](resources/OrientDB-k8s-app-architecture.jpeg)

This solution follows [Orientdb Distributed Architecture](https://orientdb.com/docs/3.0.x/distributed/Distributed-Architecture.html#distributed-architecture) for replication and HA.

A Kubernetes StatefulSet manages all of the OrientDB pods in this application. By default 3 servers of OrientDB will run in seperate pods and will discover each other via hazelcast tcp/ip discovery protocol. OrientDB uses an internal binary protocol for replication. Each pod will get 1 PVC for Storage and 1 PVC for Backup.

Access to the OrientDB Studio service is authenticated by default.



# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! To install this OrientDB app to a Google
Kubernetes Engine cluster using Google Cloud Marketplace, follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/orientdb).

## Command-line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/orientdb)

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, then `gcloud`, `kubectl`, Docker, and Git are installed in your
environment by default.

* [gcloud](https://cloud.google.com/sdk/gcloud/)
* [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
* [docker](https://docs.docker.com/install/)
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [openssl](https://www.openssl.org/)
* [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine (GKE) cluster

Create a new cluster from the command line:

```shell
export CLUSTER=orientdb-cluster
export ZONE=us-west1-a
export PROJECT_ID=<GCP_Project_ID>

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo, and the associated tools repo:

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, StatefulSets, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following
command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found at
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the app

Navigate to the `orientdb` directory:

```shell
cd click-to-deploy/k8s/orientdb
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app. For most cases, you can use
the `default` namespace.

```shell
export APP_INSTANCE_NAME=orientdb-1
export NAMESPACE=default
```

Configure the image tag:

```shell
# For OrientDB version 2.2.x
export TAG=2.2

# For OrientDB version 3.0.x
export TAG=3.0
```

Configure container images:

```shell
export IMAGE_ORIENTDB="marketplace.gcr.io/google/orientdb"
export IMAGE_DEPLOYER="gcr.io/cloud-marketplace-tools/k8s/deployer_helm:0.8.0"
```

Set the number of replicas for OrientDB:
```shell
export REPLICAS=3
```

Set or generate root password for OrientDB Studio UI:

```shell
export ORIENTDB_ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1 | tr -d '\n')
```

Set the storage class for the persistent volume of OrientDB's main storage and backup storage:

 * Set the StorageClass name. You can select your existing StorageClass name for persistent disk of OrientDB storage.
 * Set the persistent disk's size for main storage. The default disk size is "5Gi".
 * Set the persistent disk's size for backup storage. The default disk size is "2Gi".
> Note: "ssd" type storage is recommended for OrientDB, as it uses local disk to store and retrieve keys and values.
> To create a StorageClass for dynamic provisioning of SSD persistent volumes, check out [this documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/ssd-pd) for more detailed instructions.
```shell
export STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export PERSISTENT_STORAGE_SIZE="5Gi"
export PERSISTENT_BACKUP_SIZE="2Gi"
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than `default`, or the namespace does not exist
yet, run the command below to create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template chart/orientdb \
  --name "${APP_INSTANCE_NAME}" \
  --namespace "${NAMESPACE}" \
  --set orientdb.image.repo="${IMAGE_ORIENTDB}" \
  --set orientdb.image.tag="${TAG}" \
  --set deployer.image="${IMAGE_DEPLOYER}" \
  --set orientdb.replicas="${REPLICAS}" \
  --set orientdb.persistence.storageClass="${STORAGE_CLASS}" \
  --set orientdb.persistence.storage.size="${PERSISTENT_STORAGE_SIZE}" \
  --set orientdb.persistence.backup.size="${PERSISTENT_BACKUP_SIZE}" \
  --set orientdb.rootPassword="${ORIENTDB_ROOT_PASSWORD}" \
  > ${APP_INSTANCE_NAME}_manifest.yaml
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Cloud Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}?project=${PROJECT_ID}"
```

To view the app, open the URL in your browser.

### Access to OrientDB Studio web console

The deployed service of OrientDB is ClusterIP type, so you can reach to OrientDB Studio UI within a Kubernetes cluster by port-forwarding. To achieve this run below commands:

```shell
# Get root user credentials of OrientDB Studio UI
ORIENTDB_ROOT_PASSWORD=$(kubectl get secret --namespace \
  ${NAMESPACE} ${APP_INSTANCE_NAME}-orientdb-secret \
  -o jsonpath="{.data.root-password}" | base64 --decode)

echo "username: root"
echo "password: ${ORIENTDB_ROOT_PASSWORD}"

# Forward OrientDB Studio port to local workspace
kubectl port-forward svc/${APP_INSTANCE_NAME}-orientdb-svc --namespace ${NAMESPACE} 2480
```

Then visit [http://localhost:2480](http://localhost:2480) on
your web browser.
During first login you will have to create database with `root` credentials.

# Scaling

## Scaling the cluster up or down

By default, the OrientDB Distributed cluster starts with 3 replicas.

To change the number of replicas, use the following command, where `REPLICAS` is desired number of replicas:

```
export REPLICAS=4
kubectl scale statefulsets "${APP_INSTANCE_NAME}-orientdb" \
  --namespace "${NAMESPACE}" --replicas="${REPLICAS}"
```

In the case of scaling down, this option reduces the number of replicas without disconnecting nodes from the cluster.
Scaling down will also leave the `persistentvolumeclaims` of your StatefulSet untouched.

# Backup and Restore

## OrientDB 3.0.x Database Backup

The following steps are based on the [OrientDB 3.0.x Backup and Restore procedure](http://orientdb.com/docs/3.0.x/admin/Backup-and-Restore.html)

#### Create backup job:

This backup job will create a backup for all available databases or for a single database if you define.

> **NOTE**: *Backup file will be stored inside `/orientdb/backup` directory of first node `${APP_INSTANCE_NAME}-orientdb-0` of OrientDB cluster.*

```shell
# navigate to the orientdb/scripts directory
cd click-to-deploy/k8s/orientdb/scripts

# Set mandatory variables like below:
export APP_INSTANCE_NAME=orientdb-1

# Optional:
export NAMESPACE=default

# Provide single name of database you want to backup
#  or set to 'all' to backup all available databases
export DATABASE=all
```

Create backup job manifest file with `./create_backup_manifest.sh` script
```shell
./create_backup_manifest.sh
```
>**Note**: *Following steps are also included in scripts, so you can just run and follow instructions in output.*

Next steps to backup database:

```shell
## 1. Scale down StatefulSet to 0
## WARNING: It will stop all running database nodes.

kubectl -n ${NAMESPACE} scale statefulset \
	${APP_INSTANCE_NAME}-orientdb --replicas=0

## 2. Create Backup job:

kubectl apply -f ${APP_INSTANCE_NAME}-backup-${DATABASE}-job.yaml

## Check if job status is Completed:

kubectl -n ${NAMESPACE} get pods \
	-l job-name=${APP_INSTANCE_NAME}-backup-job

## 4. After completion scale back OrientDB StatefulSet back to same replica size

kubectl -n ${NAMESPACE} scale statefulset \
	${APP_INSTANCE_NAME}-orientdb --replicas=3

## 5. To see all available backup files on first node, run:

kubectl -n ${NAMESPACE} exec -it \
	${APP_INSTANCE_NAME}-orientdb-0 -- bash -c 'ls /orientdb/backup/'
```
## OrientDB 3.0.x Database Restore


#### Create restore job:

This restore job will restore only single database which you define.

> **NOTE**: *Restore file should exist inside `/orientdb/backup` directory of first node `${APP_INSTANCE_NAME}-orientdb-0` of OrientDB cluster and also database you want to restore should be created before.
Steps are also included in scripts so you can just run and follow instructions in output.*

```shell
# navigate to the orientdb/scripts directory
cd click-to-deploy/k8s/orientdb/scripts

# Set mandatory variables like below:
export APP_INSTANCE_NAME=orientdb-1
export DATABASE=yourDB

# export RESTORE_FILE variable which should exist inside '/orientdb/backup' directory of first node of cluster and should contain full name of backup file.
# To list available backup files, run:
kubectl -n ${NAMESPACE} exec -it ${APP_INSTANCE_NAME}-orientdb-0 -- bash -c 'ls /orientdb/backup/'

export RESTORE_FILE=${DATABASE}-XYZ.zip

# Optional:
export NAMESPACE=default
```

Create restore job manifest file with `./create_restore_manifest.sh` script
```shell
./create_restore_manifest.sh
```
Before starting restore procedure if you have local backup file on your workstation, then you need to copy your backup file to `/orientdb/backup` directory of `${APP_INSTANCE_NAME}-orientdb-0` node:

```shell
kubectl -n ${NAMESPACE} cp ${RESTORE_FILE} ${APP_INSTANCE_NAME}-orientdb-0:/orientdb/backup
```
To list available backup files in first node, run:
```shell
kubectl -n ${NAMESPACE} exec -it \
	${APP_INSTANCE_NAME}-orientdb-0 -- bash -c 'ls /orientdb/backup/'
```
Next steps to restore database:

> Make sure you that database you want to restore already created in this OrientDB cluster.

```shell
## 1. Scale down StatefulSet to 0
## WARNING: It will stop all running database nodes.

kubectl -n ${NAMESPACE} scale statefulset \
	${APP_INSTANCE_NAME}-orientdb --replicas=0

## 2. Create Restore job:

kubectl apply -f ${APP_INSTANCE_NAME}-restore-${DATABASE}-job.yaml

## 3. Check if job status is Completed:

kubectl -n ${NAMESPACE} get pods \
	-l job-name=${APP_INSTANCE_NAME}-restore-job

## 4. After completion scale back OrientDB StatefulSet back to same replica size

kubectl -n ${NAMESPACE} scale statefulset \
	${APP_INSTANCE_NAME}-orientdb --replicas=3
```

# Upgrading the app

Before upgrading, we recommend that you back up your all OrientDB databases, using the [backup step](#backup-and-restore). For additional information about upgrades, see the [OrientDB Upgrade documentation]([https://orientdb.com/docs/last/Upgrade.html](https://orientdb.com/docs/last/Upgrade.html)).

The OrientDB StatefulSet is configured to roll out updates automatically. Start the update by patching the StatefulSet with a new image reference:

```shell
kubectl set image statefulset ${APP_INSTANCE_NAME}-orientdb --namespace ${NAMESPACE} \
  "orientdb=[NEW_IMAGE_REFERENCE]"
```

Where `[NEW_IMAGE_REFERENCE]` is the Docker image reference of the new image that you want to use.

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

2.  From the list of apps, click **OrientDB**.

3.  On the Application Details page, click **Delete**.

## Using the command-line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=orientdb-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend using a `kubectl` version that is the same as the
> version of your cluster. Using the same version for `kubectl` and the cluster
> helps to avoid unforeseen issues.

#### Delete the deployment with the generated manifest file

Run `kubectl` on the expanded manifest file:
> **WARNING:** This will also delete your `persistentVolumeClaim`
> for ActiveMQ, which means that you will lose all of your ActiveMQ data.

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace ${NAMESPACE}
```

#### Delete the deployment by deleting the Application resource

If you don't have the expanded manifest file, delete the
resources by using types and a label:

```shell
kubectl delete application,statefulset,secret,service \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

Deleting the `Application` resource will delete all of your
deployment's resources, except for `PersistentVolumeClaim`. To
remove the `PersistentVolumeClaim`s with their attached persistent
disks, run the following `kubectl` command:

```shell
kubectl delete persistentvolumeclaims \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

