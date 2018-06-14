# Overview

Elasticsearch is an open-source search engine that provides a distributed, multitenant-capable
full-text search engine with an HTTP web interface and schema-free JSON documents..

[Learn more](https://www.elastic.co/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Elasticsearch app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/elasticsearch).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command-line.

```shell
export CLUSTER=marketplace-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to talk to the new cluster.

```shell
gcloud container clusters get-credentials "$CLUSTER"
```

#### Clone this repo

Clone this repo and the associated tools repo.

```shell
gcloud source repos clone google-click-to-deploy --project=k8s-marketplace-eap
gcloud source repos clone google-marketplace-k8s-app-tools --project=k8s-marketplace-eap
```

#### Install the Application resource definition

Do a one-time setup for your cluster to understand Application resources.

```shell
kubectl apply -f google-marketplace-k8s-app-tools/crd/*
```

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `elasticsearch` directory.

```shell
cd google-click-to-deploy/k8s/elasticsearch
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export APP_INSTANCE_NAME=elasticsearch-1
export NAMESPACE=default
```

Specify the number of replicas for the Elasticsearch server:

```shell
export REPLICAS=2
```

Configure the container images.

```shell
export IMAGE_ELASTICSEARCH="gcr.io/k8s-marketplace-eap/google/elasticsearch:latest"
export IMAGE_INIT="gcr.io/k8s-marketplace-eap/google/elasticsearch/ubuntu16_04:latest"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
for i in "IMAGE_ELASTICSEARCH" "IMAGE_INIT"; do
  repo=`echo ${!i} | cut -d: -f1`;
  digest=`docker pull ${!i} | sed -n -e 's/Digest: //p'`;
  export $i="$repo@$digest";
  env | grep $i;
done
```

#### Expand the manifest template

Use `envsubst` to expand the template. It is recommended that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_ELASTICSEARCH $IMAGE_INIT $REPLICAS' \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply to Kubernetes

Use `kubectl` to apply the manifest to your Kubernetes cluster.

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

Point your browser to:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

### Expose Elasticsearch service (optional)

By default, the application does not have an external IP. Run the
following command to expose an external IP:

```
kubectl patch svc "$APP_INSTANCE_NAME-elasticsearch-svc" \
  --namespace "$NAMESPACE" \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

# Obtain Elasticsearch URL

If you run your Elasticsearch cluster behind a LoadBalancer service, obtain the service IP to
run administrative operations against the REST API:

```
SERVICE_IP=$(kubectl get \
  --namespace ${NAMESPACE} \
  svc ${APP_INSTANCE_NAME}-elasticsearch-svc \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

ELASTIC_URL="http://${SERVICE_IP}:9200"
```

You could also use a local proxy to access the service that is not exposed publicly.
Run the following command in a separate background terminal:

```shell
# select a local port to play the role of proxy
KUBE_PROXY_PORT=8080
kubectl proxy -p $KUBE_PROXY_PORT
```

In you main terminal:

```shell
KUBE_PROXY_PORT=8080
PROXY_BASE_URL=http://localhost:$KUBE_PROXY_PORT/api/v1/proxy
ELASTIC_URL=$PROXY_BASE_URL/namespaces/$NAMESPACE/services/$APP_INSTANCE_NAME-elasticsearch-svc:http
```

In both cases, you should have an `ELASTIC_URL` environment variable that points to Elasticsearch
base URL. You can check this by running `curl`:

```shell
curl "${ELASTIC_URL}"
```

In the response, you should see a message including Elasticsearch characteristic tagline:

```shell
"tagline" : "You Know, for Search"
```

Note that it might take some time for the external IP to be provisioned.

### Scale the cluster

Scale the number of master node replicas by the following command:

```
kubectl scale statefulsets "$APP_INSTANCE_NAME-elasticsearch" \
  --namespace "$NAMESPACE" --replicas=<new-replicas>
```

By default, there are 2 replicas to satisfy the minimum master quorum.
To increase resilience, it is recommended to scale the number of replicas
to at least 3.

For more information about the StatefulSets scaling, check the
[Kubernetes documentation](https://kubernetes.io/docs/tasks/run-application/scale-stateful-set/#kubectl-scale).

# Snapshot and restore

This procedure is based on the official Elasticsearch documentation about
[Snapshot And Restore](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html).

In this procedure we will use NFS storage built on top of a StatefulSet in Kubernetes. You could
also consider using other NFS providers or one of the repository plugins supported by Elasticsearch. 

## Snapshot

### Create a backup infrastructure

To create a NFS server on Kubernetes and create a shared disk to be used for backup,
run the script from `scripts/create-backup-infra.sh`: 

```shell
scripts/create-backup-infra.sh \
  --app elasticsearch-1 \
  --namespace default \
  --disk-size 10Gi \
  --backup-claim elasticsearch-1-backup
```

### Patch Elasticsearch StatefulSet to mount a backup disk

Your Elasticsearch StatefulSet needs to be patched to mount the backup disk. To run the patch
and automatically perform a rolling update on the StatefulSet, use the script from
`scripts/patch-sts-for-backup.sh`. 

```shell
scripts/patch-sts-for-backup.sh \
  --app elasticsearch-1 \
  --namespace default \
  --backup-claim elasticsearch-1-backup
```

### Register the snapshot repository in Elasticsearch cluster

Obtain the URL for Elasticsearch API (instructions are available above). Environment variable of
`ELASTIC_URL` should point to Elasticsearch REST API.

To register your new backup repository:

```shell
curl -X PUT "$ELASTIC_URL/_snapshot/es_backup" -H 'Content-Type: application/json' -d '{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/backup"
  }
}'
```

### Create a snapshot

To create a snapshot of data in your indices, call the REST API:

```shell
curl -X PUT "$ELASTIC_URL/_snapshot/es_backup/snapshot_1?wait_for_completion=true"
```

## Restore

For the needs of this instruction, we will assume that you have a "clean" installation of
Elasticsearch cluster and you want to restore all data from a snapshot.

### Patch Elasticsearch StatefulSet to mount a backup disk

Let's assume that environment variable of `ES_BACKUP_CLAIM` contains the name of a Persistent Volume
Claim that was previously used as a snapshot repository in Elasticsearch cluster in the version
compatible with the new cluster.

Run the following command to run a rolling update for mounting the disk to all Elasticsearch Pods
of your installation:

```shell
scripts/patch-sts-for-backup.sh \
  --app elasticsearch-1 \
  --namespace default \
  --backup-claim "$ES_BACKUP_CLAIM"
```

### Register the snapshot repository

Call exactly the same command as in case of registering a repository for backup above.

After the repository is mounted, you can list all of the available snapshots to be restored by
calling:

```shell
curl "$ELASTIC_URL/_snapshot/es_backup/_all"
```

To restore a snapshot called `snapshot_1`, run the following command:

```shell
curl -X POST "$ELASTIC_URL/_snapshot/es_backup/snapshot_1/_restore"
```

# Update procedure

For more background about the rolling update procedure, please check the
[official documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/rolling-upgrades.html).

Before starting the update procedure on your cluster, we strongly advise to
prepare a backup of your installation in order to eliminate the risk of losing
your data.

## Perform the update on cluster nodes

### Patch the StatefulSet with the new image

Start with assigning the new image to your StatefulSet definition:

```
IMAGE_ELASTICSEARCH=<put your new image reference here>

kubectl set image statefulset "${APP_INSTANCE_NAME}-elasticsearch" \
  --namespace $NAMESPACE "$IMAGE_ELASTICSEARCH"
```

After this operation the StatefulSet has a new image configured for its containers, but the pods
will not automatically restart due to the OnDelete update strategy set on the StatefulSet.

### Run the `upgrade.sh` script to run the rolling update procedure

Make sure that the cluster is healthy before proceeding:

```shell
curl $ELASTIC_URL/_cluster/health?pretty
```

Run the `scripts/upgrade.sh` script. This script will take down and update one replica at a time -
it should print out diagnostic messages. You should be done when the script finishes.

# Uninstall the Application

## Using GKE UI

Navigate to `GKE > Applications` in GCP console. From the list of applications, click on the one
that you wish to uninstall.

On the new screen, click on the `Delete` button located in the top menu. It will remove
the resources attached to this application.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=elasticsearch-1
export NAMESPACE=default
```

### Prepare the manifest file

If you still have the expanded manifest file used for the installation, you can skip this part.
Otherwise, generate it again. You can use a simplified variables substitution:

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE' \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

### Delete the resources using `kubectl delete`

NOTE: Please keep in mind that `kubectl` guarantees support for Kubernetes server in +/- 1 versions.
  It means that for instance if you have `kubectl` in version 1.10.&ast; and Kubernetes 1.8.&ast;,
  you may experience incompatibility issues, like not removing the StatefulSets with
  apiVersion of apps/v1beta2.

Run `kubectl` on expanded manifest file matching your installation:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

### Delete the persistent volumes of your installation

By design, removal of StatefulSets in Kubernetes does not remove the PersistentVolumeClaims that
were attached to their Pods. It protects your installations from mistakenly deleting stateful data.

If you wish to remove the PersistentVolumeClaims with their attached persistent disks, run the
following `kubectl` command:

```shell
# specify the variables values matching your installation:
export APP_INSTANCE_NAME=elasticsearch-1
export NAMESPACE=default

kubectl delete persistentvolumeclaims \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```
