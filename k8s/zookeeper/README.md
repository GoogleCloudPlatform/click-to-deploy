# Overview

ZooKeeper is a high-performance coordination service for distributed applications. It exposes common services - such as naming,
configuration management, synchronization, and group services - in a simple interface so you don't have to write them from scratch.
 You can use it off-the-shelf to implement consensus, group management, leader election, and presence protocols. Moreover you can also build on it for your own specific needs.

For more information about ZooKeeper, see the [ZooKeeper website](https://zookeeper.apache.org/doc/r3.4.14/).

## About Google Click to Deploy

Popular open source software stacks on Kubernetes packaged by Google and made available in Google Cloud Marketplace.

## Design

![Architecture diagram](resources/zookeeper-k8s-app-architecture.png)

### ZooKeeper application contains:

- An Application resource, which collects all the deployment resources into one logical entity.
- A PodDisruptionBudget for the ZooKeeper StatefulSet.
- A PersistentVolume and PersistentVolumeClaim for each Pod ZooKeeper.
- A StatefulSet with Application.
- A Services, `zk-client` which exposes endpoint for clients of ZooKeeper, `zk-internal` for master election and replications.

ZooKeeper exposing by service with type ClusterIP, which makes it available  only in cluster network.
All data is stored on PVC, which makes the application more stable.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Sample Application to a Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/zookeeper).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local workstation in the
further instructions.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_working_dir=k8s/zookeeper)

### Prerequisites

#### Set up command line tools

You'll need the following tools in your environment:

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [docker](https://docs.docker.com/install/)
- [openssl](https://www.openssl.org/)
- [helm](https://helm.sh/docs/using_helm/#installing-helm)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a cluster from the command line. If you already have a cluster that
you want to use, this step is optional.

```shell
export CLUSTER=zookeeper-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

#### Configure kubectl to connect to the cluster

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

To set up your cluster to understand Application resources, run the following command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once for each cluster.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps) community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the application

Navigate to the `zookeeper` directory:

```shell
cd click-to-deploy/k8s/zookeeper
```

#### Configure the application with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the application. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=zookeeper
export NAMESPACE=default
```


Configure the container image:

```shell
TAG=3.4
IMAGE_ZOOKEEPER_REPO=marketplace.gcr.io/google/zookeeper

export IMAGE_ZOOKEEPER=${IMAGE_ZOOKEEPER_REPO}:${TAG}
export IMAGE_ZOOKEEPER_EXPORTER=${IMAGE_ZOOKEEPER_REPO}/exporter:${TAG}
export IMAGE_METRICS_EXPORTER=${IMAGE_ZOOKEEPER_REPO}/prometheus-to-sd:${TAG}
```

The image above is referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images,
until you are ready to upgrade. To get the digest for the image, use the
following script:

```shell
for i in "IMAGE_ZOOKEEPER" "IMAGE_ZOOKEEPER_EXPORTER" "IMAGE_METRICS_EXPORTER" ; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```

Define amount of replicas for ZooKeeper:

> **NOTE:** This number should be odd for normal work of ZooKeeper.

```shell
export ZOOKEEPER_REPLICAS=3
```

Request amount of memory and CPU for each ZooKeeper Pod:

```shell
export ZOOKEEPER_MEMORY_REQUEST=1250Mi
export ZOOKEEPER_CPU_REQUEST=300m
```

Define basic parameters of ZooKeeper:

> **NOTE:** Detailed explanation of variables you can find in [ZooKeeper Administrator's Guide](https://zookeeper.apache.org/doc/r3.4.14/zookeeperAdmin.html).

```shell
export ZOOKEEPER_TICKTIME=2000
export ZOOKEEPER_CLIENT_MAX_CNXNX=60
export ZOOKEEPER_AUTO_PURGE_SNAP_RETAIN_COUNT=3
export ZOOKEEPER_PURGE_INTERVAL=24
export ZOOKEEPER_HEAP_SIZE=1000M
export ZOOKEEPER_VOLUME_SIZE=10Gi
```

Enable Stackdriver Metrics Exporter:

> **NOTE:** Your GCP project should have Stackdriver enabled. For non-GCP clusters, exporting metrics to Stackdriver is not supported yet.

By default the integration is disabled. To enable it, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=false
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/zookeeper \
--name "${APP_INSTANCE_NAME}" \
--namespace "${NAMESPACE}" \
--set metrics.enabled=${METRICS_EXPORTER_ENABLED} \
--set metrics.image=${IMAGE_METRICS_EXPORTER} \
--set exporter.image.name=${IMAGE_ZOOKEEPER_REPO}/exporter \
--set exporter.image.tag=${TAG} \
--set zookeeper.image.name=${IMAGE_ZOOKEEPER_REPO} \
--set zookeeper.image.tag=${TAG} \
--set zookeeper.zkReplicas=${ZOOKEEPER_REPLICAS} \
--set zookeeper.zkTicktime=${ZOOKEEPER_TICKTIME} \
--set zookeeper.zkMaxClientCnxns=${ZOOKEEPER_CLIENT_MAX_CNXNX} \
--set zookeeper.zkAutopurgeSnapRetainCount=${ZOOKEEPER_AUTO_PURGE_SNAP_RETAIN_COUNT} \
--set zookeeper.zkPurgeInterval=${ZOOKEEPER_PURGE_INTERVAL} \
--set zookeeper.memoryRequest=${ZOOKEEPER_MEMORY_REQUEST} \
--set zookeeper.cpuRequest=${ZOOKEEPER_CPU_REQUEST} \
--set zookeeper.zkHeapSize=${ZOOKEEPER_HEAP_SIZE} \
--set zookeeper.volumeSize=${ZOOKEEPER_VOLUME_SIZE} > ${APP_INSTANCE_NAME}_manifest.yaml
```
#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the GCP Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

# Using the ZooKeeper

By default, the application is not exposed externally. To get access to ZooKeeper CLI, run the following command:

```bash
kubectl exec -it --namespace $NAMESPACE $APP_INSTANCE_NAME-zk-0 -- zkCli.sh -server localhost:2181
```

# Application metrics

## ZooKeeper metrics

The application is configured to expose its metrics through
[ZooKeeper Exporter](https://github.com/carlpett/zookeeper_exporter) in
the
[Prometheus format](https://github.com/prometheus/docs/blob/master/content/docs/instrumenting/exposition_formats.md).

You can access the metrics at `[ZOOKEEPER_CLUSTER_IP]:9141/metrics`, where
`[ZOOKEEPER_CLUSTER_IP]` is the IP address of Pod on Kubernetes
cluster.

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

# Scaling

ZooKeeper does not support auto-scaling for application, it can be reinstalled with bigger amount of nodes.

# Backup and restore

For information on backing up your ZooKeeper data, see the [ZooKeeper documentation](https://zookeeper.apache.org/doc/r3.4.14/zookeeperAdmin.html#sc_dataFileManagement).

# Uninstall the Application

## Using the Google Cloud Platform Console

1. In the GCP Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of applications, click **ZooKeeper**.

1. On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=zookeeper
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
kubectl delete application,deployment,service,pvc,secret \
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

```shell
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```
