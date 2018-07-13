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
- [cqlsh](https://pypi.org/project/cqlsh/)

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command-line.

```shell
export CLUSTER=marketplace-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to talk to the new cluster.

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo.

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

Do a one-time setup for your cluster to understand Application resources.

```shell
kubectl apply -f click-to-deploy/k8s/vendor/marketplace-tools/crd/*
```

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `cassandra` directory.

```shell
cd click-to-deploy/k8s/cassandra
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
for i in "IMAGE_CASSANDRA"; do
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
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_CASSANDRA $REPLICAS' \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply to Kubernetes

Use `kubectl` to apply the manifest to your Kubernetes cluster.

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

Deploying can take a few minutes, please wait.

#### View the app in the Google Cloud Console

Point your browser to:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

### Check Cassandra cluster

If deployment is successful, you should be able to check status of Cassandra cluster.

To do this, use `nodetool status` command on one of containers. `nodetool` is Cassandra
specific tool to manage Cassandra cluster. It is part of Cassandra container image.

```shell
kubectl exec "${APP_INSTANCE_NAME}-cassandra-0" --namespace "${NAMESPACE}" -c cassandra -- nodetool status
```

### Access Cassandra service (internal)

It is possible to connect to Cassandra without exposing it to public access.

To do this, please connect from container inside K8s cluster using hostname
`$APP_INSTANCE_NAME-cassandra-0.$APP_INSTANCE_NAME-cassandra-svc.$NAMESPACE.svc.cluster.local`

### Access Cassandra service (via `kubectl port-forward`)

You could also use a local proxy to access the service that is not exposed publicly.
Run the following command in a separate background terminal:

```shell
 kubectl port-forward "${APP_INSTANCE_NAME}-cassandra-0" 9042:9042 --namespace "${NAMESPACE}"
 ```

In you main terminal:

```shell
cqlsh --cqlversion=3.4.4
```

In the response, you should see a Cassandra welcome message:

```shell
Use HELP for help.
cqlsh>
```

### Access Cassandra service (external)
By default, the application does not have an external IP.

[Please configure Cassandra access control, while exposing it to public access.](https://www.datastax.com/dev/blog/role-based-access-control-in-cassandra)

#### Exposing Cassandra cluster

It is possible to expose the Cassandra (although it is not a suggested approach)

```shell
envsubst '${APP_INSTANCE_NAME}' < scripts/external.yaml.template > scripts/external.yaml
kubectl apply -f scripts/external.yaml --namespace "${NAMESPACE}"
```

Note that it might take some time for the external IP to be provisioned.

#### Extract IP addess

Get the external IP of the Cassandra service invoking `kubectl get`

```shell
CASSANDRA_IP=$(kubectl get svc $APP_INSTANCE_NAME-cassandra-external-svc \
  --namespace $NAMESPACE \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo $CASSANDRA_IP
```

It can take few seconds to provide this IP.

With this IP, we can connect by `cqlsh` to Cassandra, for example

```shell
CQLSH_HOST=$CASSANDRA_IP cqlsh --cqlversion=3.4.4
```

# Scaling

### Scale the cluster up

Scale the number of replicas up by the following command:

```shell
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

To scale down by script, please invoke

```shell
<SCRIPT DIR>/scale_down.sh --desired_number 3 \
                           --namespace "${NAMESPACE}" \
                           --app_instance_name "${APP_INSTANCE_NAME}"
```

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

### Delete the resources

> **NOTE:** Please keep in mind that `kubectl` guarantees support for Kubernetes server in +/- 1 versions.
> It means that for instance if you have `kubectl` in version 1.10.&ast; and Kubernetes 1.8.&ast;,
> you may experience incompatibility issues, like not removing the StatefulSets with
> apiVersion of apps/v1beta2.

If you still have the expanded manifest file used for the installation, you can use it to delete the resources.
Run `kubectl` on expanded manifest file matching your installation:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

Otherwise, delete the resources by indication of types and a label:

```shell
kubectl delete statefulset,service \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```
### Delete the persistent volumes of your installation

By design, removal of StatefulSets in Kubernetes does not remove the PersistentVolumeClaims that
were attached to their Pods. It protects your installations from mistakenly deleting stateful data.

If you wish to remove the PersistentVolumeClaims with their attached persistent disks, run the
following `kubectl` commands:

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

# Backup & Restore

### Backup

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=cassandra-1
export NAMESPACE=default
```

To backup Cassandra, `nodetool snapshot` command must be executed on each node to
get eventually consistent backup. Script `scripts/backup.sh` does following steps:

1. Upload `make_backup.sh` script to each container.
1. Run this scripts.
1. Gather packed data and downloads them to invoking machine.

After running this script, there exists `backup-$NODENUMBER.tar.gz` files, that
contain whole backup.

Also, database schema and token information is also backed up.

Please run it with key space

```shell
<SCRIPT DIR>/backup.sh --keyspace demo \
                       --namespace "${NAMESPACE}" \
                      --app_instance_name "${APP_INSTANCE_NAME}"
```

This script will generate backup files. For each Cassandra node one archive will
be generated. For whole cluster one schema is backed up and token ring is backed
up.

### Restoring

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=cassandra-1
export NAMESPACE=default
```

To restore Cassandra, `sstableloader` tool is used. This is automated via
`scripts/restore.sh`. Please run this script from directory with backup files,
providing as arguments key space and number of generated archives.

```shell
<SCRIPT DIR>/restores.sh   --keyspace demo \
                           --namespace "${NAMESPACE}" \
                           --app_instance_name "${APP_INSTANCE_NAME}"
```

This script will recreate schema and upload data. Clusters (source and
destination) can have different number of nodes.

# Update procedure

For more background about the rolling update procedure, please check the
[Upgrade Guide](https://docs.datastax.com/en/upgrade/doc/upgrade/datastax_enterprise/upgrdDSE.html).

Before starting the update procedure on your cluster, we strongly advise to
prepare a backup of your installation in order to eliminate the risk of losing
your data.

## Perform the update on cluster nodes

### Patch the StatefulSet with the new image

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=cassandra-1
export NAMESPACE=default
```

Assign the new image to your StatefulSet definition:

```shell
IMAGE_CASSANDRA=<put your new image reference here>

kubectl set image statefulset "${APP_INSTANCE_NAME}-cassandra" \
  --namespace "${NAMESPACE}" "cassandra=${IMAGE_CASSANDRA}"
```

After this operation the StatefulSet has a new image configured for its containers, but the pods
will not automatically restart due to the OnDelete update strategy set on the StatefulSet.

### Run the `upgrade.sh` script to run the rolling update procedure

Run the `scripts/upgrade.sh` script. This script will take down and update one replica at a time -
it should print out diagnostic messages. You should be done when the script finishes.

```shell
<SCRIPT DIR>/upgrade.sh    --namespace "${NAMESPACE}" \
                           --app_instance_name "${APP_INSTANCE_NAME}"

```
