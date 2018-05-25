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
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_ELASTICSEARCH $IMAGE_INIT' \
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

### Expose Elasticsearch service

By default, the application does not have an external IP. Run the
following command to expose an external IP:

```
kubectl patch svc "$APP_INSTANCE_NAME-elasticsearch-svc" \
  --namespace "$NAMESPACE" \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

### Access Elasticsearch service

Get the external IP of the Elasticsearch service and visit
the URL printed below in your browser.

```
SERVICE_IP=$(kubectl get \
  --namespace ${NAMESPACE} \
  svc ${APP_INSTANCE_NAME}-elasticsearch-svc \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "http://${SERVICE_IP}:9200"
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

# Backup and restore

TODO

# Update procedure

For detailed instructions about the update procedure, please check the
[official documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/rolling-upgrades.html).

Before starting the update procedure on your cluster, we strongly advise to
prepare a backup of your installation in order to eliminate the risk of losing
your data.

## Background

Elasticsearch supports a procedure of a rolling update since version 5.6. In
case of this application though, the rolling update means that it is possible to
update particular nodes, one by one, in a running cluster. This procedure should
not be mixed with Kubernetes rolling update of a StatefulSet, because it
requires additional manual steps from the administrator before and after the
update of each node.

## Prepare the environment

WARNING: prepare a backup of your installation before approaching further steps.

Obtain the service IP to run administrative operations against the REST API:

```
SERVICE_IP=$(kubectl get \
  --namespace ${NAMESPACE} \
  svc ${APP_INSTANCE_NAME}-elasticsearch-svc \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

ELASTIC_URL="http://${SERVICE_IP}:9200"
```

The application is installed by default with the `updateStrategy` of "OnDelete"
assigned to the StatefulSet. If your configuration was chenged or if you are
unsure if it still up to date, run the following command to ensure the right
`updateStrategy`:

```
kubectl patch statefulset ${APP_INSTANCE_NAME}-elasticsearch \
  --namespace $NAMESPACE \
  -p '{"spec":{"updateStrategy":{"type":"OnDelete"}}}'
```

## Perform the update on cluster nodes

### Patch the StatefulSet with the new image

Start with assigning the new image to your StatefulSet definition:

```
NEW_IMAGE=<put your new image reference here>

kubectl patch statefulset ${APP_INSTANCE_NAME}-elasticsearch \
  --namespace $NAMESPACE --type='json' \
  -p="[{\"op\": \"replace\", \"path\": \"/spec/template/spec/containers/0/image\", \"value\": \"${NEW_IMAGE}\"}]"
```

After this operation the StatefulSet has a new image configured for its
containers, but considering the `OnDelete` strategy, it will not start
replacing any container until its deletion.

### Perform the update for the first node

This procedure is based on the [official documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/rolling-upgrades.html).

Disable shard allocation:

```
curl -X PUT "${ELASTIC_URL}/_cluster/settings" -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "cluster.routing.allocation.enable": "none"
  }
}'
```

Perform a synced-flush:

```
curl -X POST "${ELASTIC_URL}/_flush/synced"
```

Delete the first pod:

```
POD_TO_DELETE=${APP_INSTANCE_NAME}-elasticsearch-0
kubectl delete pod ${POD_TO_DELETE} \
  --namespace $NAMESPACE
```

At this point, the StatefulSet will take care of the pod's recreation. It will
use the new image spec to create a new pod with the same name. Old pod's persistent
volume will not be deleted and will be attached to the new one.

Wait until the new pod joined the cluster. To check for the number of nodes in
the cluster, run:

```
curl -X GET "${ELASTIC_URL}/_cat/nodes"
```

Reenable shard allocation:

```
curl -X PUT "${ELASTIC_URL}/_cluster/settings" -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "cluster.routing.allocation.enable": null
  }
}'
```

Once the new node joined the cluster, wait until the cluster recovers. Check the
status of your cluster by running:

```
curl -X GET "${ELASTIC_URL}/_cat/health"
```

The status reported for the cluster should switch from yellow to green.

### Repeat the procedure for each node in the cluster

Continue the rolling update procedure for each pod in your StatefulSet. During
the process, the cluster should be still reachable and operating normally, with
all the functionality of the older version. Only when all the nodes are updated,
the cluster will switch to the new version functionality.
