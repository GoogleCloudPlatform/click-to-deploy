# Overview

Open-source distributed event streaming platform used for high-performance data pipelines, streaming analytics, data integration, and mission-critical applications.

For more information on Apache Kafka, see the Apache Kafka [official website](https://kafka.apache.org/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

# Installation

Get up and running with a few clicks! To install this Kafka app to a Google
Kubernetes Engine (GKE) cluster by using Google Cloud Marketplace, follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/kafka).

## Command-line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/kafka)

### Prerequisites

#### Setting up command-line tools

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

#### Creating a Google Kubernetes Engine (GKE) cluster

Create a new cluster from the command line:

```shell
export CLUSTER=kakfa-cluster
export ZONE=us-west1-a
export PROJECT_ID=<GCP_Project_ID>

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Cloning this repo

Clone this repo, and the associated tools repo:

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Installing the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, StatefulSets, and so on, that you can manage as a group.

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

Navigate to the `kafka` directory:

```shell
cd click-to-deploy/k8s/kafka
```

#### Configuring the app with environment variables

Choose the instance name and namespace for the app. For most cases, you can
use the `default` namespace.

```shell
export APP_INSTANCE_NAME=kafka-1
export NAMESPACE=default
```
(Optional) Enable Stackdriver Metrics Exporter:

> **NOTE:** Your GCP project must have Stackdriver enabled. If you are using a
> non-GCP cluster, you cannot export metrics to Stackdriver.

By default, the application does not export metrics to Stackdriver. To enable
this option, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=false
```

Configure the image tag:

```shell
export TAG=8.9
export ZK_TAG=3.6
```
Configure the container images:

```shell
export IMAGE_KAFKA="marketplace.gcr.io/google/kafka"
export IMAGE_ZOOKEEPER="marketplace.gcr.io/google/kafka/zookeeper:${TAG}"
export IMAGE_EXPORTER="marketplace.gcr.io/google/kafka/exporter:${TAG}"
export IMAGE_DEPLOYER="marketplace.gcr.io/google/kafka/deployer:${TAG}"
```
Set or generate the passwords:


```shell
# Set alias for password generation

```

Set the storage class for the persistent volume of Kafka nodes and ZooKeeper nodes:

 * Set the StorageClass name. You can select your existing StorageClass name for
   the persistent disk of Kafka application storage.
 * Set the persistent disk's size for Kafka storage. The default disk size is
   `10Gi`.
 * Set the persistent disk's size for ZooKeeper storage. The default disk size
   is `5Gi`.

```shell
export STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export PERSISTENT_KAFKA_SIZE="10Gi"
export PERSISTENT_ZK_SIZE="5Gi"
```

#### Creating a namespace in your Kubernetes cluster

If you use a different namespace than `default`, or if the namespace does
not exist yet, create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Expanding the manifest template

To expand the template, use `helm template`. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template chart/kafka \
  --name-template "${APP_INSTANCE_NAME}" \
  --namespace "${NAMESPACE}" \
  --set kafka.image.repo="${IMAGE_KAFKA}" \
  --set kafka.image.tag="${TAG}" \
  --set kafka.replicas="${KAFKA_REPLICAS}" \
  --set kafka.password="${KAFKA_AUTH_PASSWORD}" \
  --set kafka.persistence.size="${PERSISTENT_KAFKA_SIZE}" \
  --set kafka.persistence.storageClass="${STORAGE_CLASS}" \
  --set kafka.exporter.image="${IMAGE_KAFKA_EXPORTER}" \
  --set exporter.image="${IMAGE_EXPORTER}" \
  --set zookeeper.image="${IMAGE_ZOOKEEPER}" \
  --set metrics.image="${IMAGE_METRICS_EXPORTER}" \
  --set metrics.exporter.enabled="${METRICS_EXPORTER_ENABLED}" \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
  ```

#### Applying the manifest to your Kubernetes cluster

To apply the manifest to your Kubernetes cluster, use `kubectl`:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```