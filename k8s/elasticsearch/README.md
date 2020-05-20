# Overview

Elasticsearch is an open-source search engine that provides a distributed,
multitenant-capable full-text search engine with an HTTP web interface and
schema-free JSON documents.

[Learn more](https://www.elastic.co/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

## Architecture

![Architecture diagram](resources/elasticsearch-architecture.png)

The application offers a basic installation of Elasticsearch.

Elasticsearch server runs in a StatefulSet, with configuration files
(`elasticsearch.yml` and `log4j2.properties`) attached through a ConfigMap.

The Service that exposes Elasticsearch is configured to serve private
connections though a ClusterIP, exposing a private IP address. It accepts
connections on ports `9200` and `9300`.

Elasticsearch requires that you have an appropriate virtual memory configuration
on the host operating system, specifically setting a minimum value of `262144`
for `vm.max_map_count`. This application configures virtual memory by running a
privileged InitContainer.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Elasticsearch app to a Google
Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/elasticsearch).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/elasticsearch)

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your
environment by default.

-   [gcloud](https://cloud.google.com/sdk/gcloud/)
-   [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
-   [docker](https://docs.docker.com/install/)
-   [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
-   [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=elasticsearch-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to connect to the new cluster.

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo:

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

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `elasticsearch` directory:

```shell
cd click-to-deploy/k8s/elasticsearch
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=elasticsearch-1
export NAMESPACE=default
```

Specify the number of replicas for the Elasticsearch cluster:

```shell
export REPLICAS=2
```

For the persistent disk provisioning of the Elasticsearch StatefulSets, you will need to:

 * Set the StorageClass name. Check your available options using the command below:
   * ```kubectl get storageclass```
   * Or check how to create a new StorageClass in [Kubernetes Documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#the-storageclass-resource)

 * Set the persistent disk's size. The default disk size is "5Gi".

```shell
export DEFAULT_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export PERSISTENT_DISK_SIZE="5Gi"
```


Enable Stackdriver Metrics Exporter:

> **NOTE:** Your GCP project must have Stackdriver enabled. If you are using a
> non-GCP cluster, you cannot export metrics to Stackdriver.

By default, application does not export metrics to Stackdriver. To enable this
option, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=false
```

Set up the image tag:

It is advised to use stable image reference which you can find on
[Marketplace Container Registry](https://marketplace.gcr.io/google/elasticsearch).
Example:

```shell
export TAG="6.3.2-20200311-092308"
```

Alternatively you can use short tag which points to the latest image for selected version.
> Warning: this tag is not stable and referenced image might change over time.

```shell
export TAG="6.3"
```

Configure the container images:

```shell
export IMAGE_ELASTICSEARCH="marketplace.gcr.io/google/elasticsearch"
export IMAGE_INIT="marketplace.gcr.io/google/elasticsearch/ubuntu16_04:${TAG}"
export IMAGE_METRICS_EXPORTER="marketplace.gcr.io/google/elasticsearch/prometheus-to-sd:${TAG}"
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace other than `default`, run the command below to
create a new namespace:

```shell
kubectl create namespace "$NAMESPACE"
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/elasticsearch \
  --name "$APP_INSTANCE_NAME" \
  --namespace "$NAMESPACE" \
  --set elasticsearch.initImage="$IMAGE_INIT" \
  --set elasticsearch.image.repo="$IMAGE_ELASTICSEARCH" \
  --set elasticsearch.image.tag="$TAG" \
  --set elasticsearch.replicas="$REPLICAS" \
  --set metrics.image="$IMAGE_METRICS_EXPORTER" \
  --set metrics.exporter.enabled="$METRICS_EXPORTER_ENABLED" \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

> NOTE: Elasticsearch Pods have an
> [Init Container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
> that sets the system property of `vm.max_map_count` set at least to 262144 on
> the hosting node. For background information, see the
> [Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html).

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

### (Optional) Expose Elasticsearch service externally

By default, the application does not have an external IP. To create an external
IP address, run the following command:

```
kubectl patch svc "$APP_INSTANCE_NAME-elasticsearch-svc" \
  --namespace "$NAMESPACE" \
  --patch '{"spec": {"type": "LoadBalancer"}}'
```

It might take some time for the external IP address to be created.

# Get the Elasticsearch URL

If you run your Elasticsearch cluster behind a LoadBalancer service, use the
following command to get the IP address. You can use the IP address to run
administrative operations using the REST API:

```
SERVICE_IP=$(kubectl get svc $APP_INSTANCE_NAME-elasticsearch-svc \
  --namespace $NAMESPACE \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

ELASTIC_URL="http://${SERVICE_IP}:9200"
```

If you haven't exposed your Elasticsearch service externally, use a local proxy
to access the service. In a separate terminal, run the following command:

```shell
# select a local port as the proxy
KUBE_PROXY_PORT=8080
kubectl proxy -p $KUBE_PROXY_PORT
```

In your main terminal, run the following commands:

```shell
KUBE_PROXY_PORT=8080
PROXY_BASE_URL=http://localhost:$KUBE_PROXY_PORT/api/v1/proxy
ELASTIC_URL=$PROXY_BASE_URL/namespaces/$NAMESPACE/services/$APP_INSTANCE_NAME-elasticsearch-svc:http
```

In both cases, the `ELASTIC_URL` environment variable points to your
Elasticsearch base URL. Verify the variable using `curl`:

```shell
curl "${ELASTIC_URL}"
```

In the response, you should see a message that has Elasticsearch's tagline:

```shell
"tagline" : "You Know, for Search"
```

# Application metrics

## Prometheus metrics

The application is configured to expose its metrics through
[Elasticsearch Exporter](https://github.com/justwatchcom/elasticsearch_exporter)
in the
[Prometheus format](https://github.com/prometheus/docs/blob/master/content/docs/instrumenting/exposition_formats.md).
For more detailed information about setting up the plugin, see the
[Elasticsearch Exporter documentation](https://github.com/justwatchcom/elasticsearch_exporter/blob/master/README.md).

You can access the metrics at `[POD_IP]:9114/metrics`, where `[POD_IP]` is the
IP address from the Kubernetes headless service
`$APP_INSTANCE_NAME-elasticsearch-prometheus-svc`.

### Configuring Prometheus to collect metrics

Prometheus can be configured to automatically collect the application's metrics.
Follow the steps in
[Configuring Prometheus](https://prometheus.io/docs/introduction/first_steps/#configuring-prometheus).

You configure the metrics in the
[`scrape_configs` section](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config).

## Exporting metrics to Stackdriver

The deployment includes a
[Prometheus to Stackdriver (`prometheus-to-sd`)](https://github.com/GoogleCloudPlatform/k8s-stackdriver/tree/master/prometheus-to-sd)
container. If you enabled the option to export metrics to Stackdriver, the
metrics are automatically exported to Stackdriver and visible in
[Stackdriver Metrics Explorer](https://cloud.google.com/monitoring/charts/metrics-explorer).

The name of each metric starts with the application's name, which you define in
the `APP_INSTANCE_NAME` environment variable.

The exporting option might not be available for GKE on-prem clusters.

> Note: Stackdriver has [quotas](https://cloud.google.com/monitoring/quotas) for
> the number of custom metrics created in a single GCP project. If the quota is
> met, additional metrics might not show up in the Stackdriver Metrics Explorer.

You can remove existing metric descriptors using
[Stackdriver's REST API](https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.metricDescriptors/delete).

### Scale the cluster

Scale the number of master node replicas using the following command:

```shell
kubectl scale statefulsets "$APP_INSTANCE_NAME-elasticsearch" \
  --namespace "$NAMESPACE" --replicas=<new-replicas>
```

By default, there are 2 replicas to satisfy the minimum master quorum. To
increase resilience, it is recommended to scale the number of replicas to at
least 3.

For more information about scaling StatefulSets, see the
[Kubernetes documentation](https://kubernetes.io/docs/tasks/run-application/scale-stateful-set/#kubectl-scale).

# Snapshot and restore

The following steps are based on the Elasticsearch documentation on
[Snapshot And Restore](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html).

These steps use NFS storage on top of a StatefulSet in Kubernetes. You could use
other NFS providers, or one of the repository plugins supported by
Elasticsearch.

## Snapshot

### Create a backup environment

To create a NFS server on Kubernetes and create a shared disk for the backup,
run [`scripts/create-backup-infra.sh`](scripts/create-backup-infra.sh):

```shell
scripts/create-backup-infra.sh \
  --app elasticsearch-1 \
  --namespace default \
  --disk-size 10Gi \
  --backup-claim elasticsearch-1-backup
```

### Patch the Elasticsearch StatefulSet to mount a backup disk

Your Elasticsearch StatefulSet needs to be patched to mount the backup disk. To
run the patch and automatically perform a rolling update on the StatefulSet, run
[`scripts/patch-sts-for-backup.sh`](scripts/patch-sts-for-backup.sh).

```shell
scripts/patch-sts-for-backup.sh \
  --app elasticsearch-1 \
  --namespace default \
  --backup-claim elasticsearch-1-backup
```

### Register the snapshot repository in the Elasticsearch cluster

[Get the URL for the Elasticsearch API](#get-the-elasticsearch-url). The
`ELASTIC_URL` points to the Elasticsearch REST API.

To register your new backup repository, run the following command:

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

These steps assume that you have a clean installation of Elasticsearch on your
cluster, and you want to restore all data from a snapshot.

### Patch the Elasticsearch StatefulSet to mount a backup disk

These steps assume that the `ES_BACKUP_CLAIM` environment variable contains the
name of a PersistentVolumeClaim that was used as a snapshot repository in
Elasticsearch cluster, and that the version of the Claim is compatible with the
new cluster.

Run the following command to run a rolling update that mounts the disk to all
the Elasticsearch Pods in your installation:

```shell
scripts/patch-sts-for-backup.sh \
  --app elasticsearch-1 \
  --namespace default \
  --backup-claim "$ES_BACKUP_CLAIM"
```

### Register the snapshot repository

Repeat [the steps](#register-the-snapshot-repository-in-elasticsearch-cluster)
for registering a snapshot repository for your backup.

After the repository is mounted, list all the available snapshots using the
following command:

```shell
curl "$ELASTIC_URL/_snapshot/es_backup/_all"
```

To restore a snapshot called `snapshot_1`, run the following command:

```shell
curl -X POST "$ELASTIC_URL/_snapshot/es_backup/snapshot_1/_restore"
```

# Updating the app

For background information about rolling updates to Elasticsearch, see the
[Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/rolling-upgrades.html).

Before starting the update procedure on your cluster, we recommend that you back
up your installation, to eliminate the risk of losing your data.

## Perform the update on cluster nodes

### Patch the StatefulSet with the new image

Start with assigning the new image to your StatefulSet definition:

```
IMAGE_ELASTICSEARCH=[NEW_IMAGE_REFERENCE]

kubectl set image statefulset "${APP_INSTANCE_NAME}-elasticsearch" \
  --namespace $NAMESPACE elasticsearch="${IMAGE_ELASTICSEARCH}"
```

After this operation, the StatefulSet has a new image configured for the
containers. However, because of the OnDelete update strategy on the StatefulSet,
the pods will not automatically restart.

### Run the `upgrade.sh` script to run the rolling update

Make sure that the cluster is healthy before proceeding:

```shell
curl $ELASTIC_URL/_cluster/health?pretty
```

Run [`scripts/upgrade.sh`](scripts/upgrade.sh). The script takes down and
updates one replica at a time.

# Uninstall the Application

## Using the Google Cloud Platform Console

1.  In the GCP Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1.  From the list of applications, click **Elasticsearch**.

1.  On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=elasticsearch-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend using a `kubectl` version that is the same as the
> version of your cluster. Using the same versions of `kubectl` and the cluster
> helps avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

If you don't have the expanded manifest file, delete the resources using types
and a label:

```shell
kubectl delete application,statefulset,service,configmap \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete the PersistentVolumeClaims

By design, the removal of StatefulSets in Kubernetes does not remove
PersistentVolumeClaims that were attached to their Pods. This prevents your
installations from accidentally deleting stateful data.

To remove the PersistentVolumeClaims with their attached persistent disks, run
the following `kubectl` commands:

```shell
# specify the variables values matching your installation:
export APP_INSTANCE_NAME=elasticsearch-1
export NAMESPACE=default

kubectl delete persistentvolumeclaims \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```
