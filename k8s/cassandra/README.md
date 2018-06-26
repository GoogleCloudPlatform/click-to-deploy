# Overview

The Apache Cassandra database management system provides asynchronous masterless replication of
large amounts of data across many servers, avoiding a single point of failure and reducing latency.

[Learn more](https://cassandra.apache.org/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Cassandra app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/cassandra).

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

Navigate to the `cassandra` directory.

```shell
cd google-click-to-deploy/k8s/cassandra
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export APP_INSTANCE_NAME=cassandra-1
export NAMESPACE=default
```

Specify the number of nodes for the Cassandra:

```shell
# Setting a single node in Cassandra cluster means single point of failure.
# For production grade system please consider at least 3 replicas.
export REPLICAS=3
```

Configure the container images.

```shell
export IMAGE_CASSANDRA="gcr.io/k8s-marketplace-eap/google/cassandra:latest"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
for var in "IMAGE_CASSANDRA"; do
  image="${!var}";
  export $var=$(docker inspect --format='{{index .RepoDigests 0}}' $image)
  env | grep $var
done
```

#### Expand the manifest template

Use `envsubst` to expand the template. It is recommended that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_CASSANDRA $REPLICAS' \
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

### Check Cassandra cluster

By default, the application does not have an external IP.
```shell
kubectl exec cassandra-1-cassandra-0 --namespace $NAMESPACE -c cassandra -- nodetool status
```

### Exposing Cassandra cluster

It is possible to provide a load balancer in front of the cluster (although it is not a suggested approach)

```shell
export APP_INSTANCE_NAME=cassandra-1
export NAMESPACE=default

envsubst '$APP_INSTANCE_NAME $NAMESPACE' scripts/external.yaml.template > scripts/external.yaml
kubectl apply -f scripts/external.yaml -n $NAMESPACE
```

### Access Cassandra service

Get the external IP of the Cassandra service invoking `kubectl get`
```shell
CASSANDRA_IP=$(kubectl get svc/$APP_INSTANCE_NAME-cassandra-external-svc \
  -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo $CASSANDRA_IP
```

It can take few seconds to provide this IP.

With this IP, we can connect by `cqlsh` to Cassandra, for example

```shell
docker run --rm -it -e CQLSH_HOST=$CASSANDRA_IP \
  launcher.gcr.io/google/cassandra3 cqlsh --cqlversion=3.4.4
```

# Scaling

### Scale the cluster up

Scale the number of replicas up by the following command:

```
kubectl scale statefulsets "$APP_INSTANCE_NAME-cassandra" \
  --namespace "$NAMESPACE" --replicas=<new-replicas>
```

By default, there are 3 replicas, to provide resilience system.

### Scale the cluster down

To scale down number of replicas, please use script `scripts/scale_down.sh`,
or manually scale down cluster in following steps.

To remove Cassandra nodes from cluster Cassandra cluster, and then pod from K8s,
start from highest numbered pod $INDEX

For each node, do following steps
1. Run `nodetool decommission` on Cassandra container
1. Scale down stateful set by one with `kubectl scale sts` command
1. Wait until pod is removed from cluster
1. Remove persistent volume and persistent volume claim belonging to that replica

Repeat this procedure until Cassandra cluster has expected number of pods

For more information about the StatefulSets scaling, check the
[Kubernetes documentation](https://kubernetes.io/docs/tasks/run-application/scale-stateful-set/#kubectl-scale).

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
export APP_INSTANCE_NAME=cassandra-1
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
  It means that for instance if you have `kubectl` in version 1.10.* and Kubernetes server 1.8.\*,
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
following `kubectl` commands:

```shell
for pv in $(kubectl get pvc --namespace $NAMESPACE \
             --selector  app.kubernetes.io/name=$APP_INSTANCE_NAME \
             --output jsonpath='{.items[*].spec.volumeName}'); do
  kubectl delete "pv/${pv}" --namespace $NAMESPACE
done

kubectl delete persistentvolumeclaims \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

# Backup & Restore

### Backup

To backup Cassandra, `nodetool snapshot` command must be executed on each node to
get eventually consistent backup. Script `scripts/backup.sh` does following steps:

1. Upload `make_backup.sh` script to each container.
1. Run this scripts.
1. Gather packed data and downloads them to invoking machine.

After running this script, there exists `backup-$NODENUMBER.tar.gz` files, that
contain whole backup.

Also, database schema and token information is also backed up.

### Restoring

*TODO: instructions for restore*

# Upgrades

*TODO: instructions for upgrades*
