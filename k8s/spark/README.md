# Overview

Apache Spark is an open-source framework and extensible platform for distributed processing.

For more information, visit the
[Spark official website](https://spark.apache.org/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

![Architecture diagram](resources/spark-k8s-app-architecture.png)

A Kubernetes StatefulSet manages Spark single master and a Deployment workload
manages the workers cluster.

This deployment is based on default Spark 3 broker with no authentication and only exposed internally in the K8s cluster.

# Installation

## Before you begin

If you are new to selling software on Google Cloud Marketplace,
[sign up to become a partner](https://cloud.google.com/marketplace/sell/).

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Spark app to
a Google Kubernetes Engine cluster by using Google Cloud Marketplace.
Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/spark).

## Command-line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or
a local workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/spark)

### Set up your environment

#### Set up your command-line tools

You'll need the following tools in your development environment. If
you are using Cloud Shell, then `gcloud`, `kubectl`, Docker, and Git
are installed in your environment by default.

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

Create a new cluster from the command-line:

```shell
export CLUSTER=spark-cluster
export ZONE=us-west1-a
export PROJECT_ID=<GCP_Project_ID>

gcloud container clusters create "${CLUSTER}" --zone "${ZONE}"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}"
```

#### Clone this repo

Clone this repo, and its associated tools repo:

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes
components, such as Services, StatefulSets, and so on, that you can
manage as a group.

To set up your cluster to understand Application resources, run the
following command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found at
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the app

Navigate to the `spark` directory:

```shell
cd click-to-deploy/k8s/spark
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=spark-1
export NAMESPACE=default
```

Set up the image tag:

It is advised to use stable image reference which you can find on
[Marketplace Container Registry](https://marketplace.gcr.io/google/spark).
Example:

```shell
export TAG="3.3.0-<BUILD_ID>"
```

Alternatively you can use short tag which points to the latest image for selected version.
> Warning: this tag is not stable and referenced image might change over time.

```shell
export TAG="3.3"
```

Configure the container images:

```shell
export IMAGE_SPARK="marketplace.gcr.io/google/spark"
```

Set the storage class for the persistent volume of Spark:

 * Set the StorageClass name. You can select your existing StorageClass name for the persistent disk of the Spark master configurations.
 * Set the persistent disk's size. The default disk size is "5Gi".
> Note: "ssd" type storage is recommended for Spark, as it uses local disk to manage its configuration.
> To create a StorageClass for dynamic provisioning of SSD persistent volumes, check out [this documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/ssd-pd) for more detailed instructions.

```shell
export STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export PERSISTENT_DISK_SIZE="5Gi"
```

By default, Spark does not enable History Server UI and Prometheus Metrics Exporter. If you want to expose them, use the variables below:

```shell
export ENABLE_PROMETHEUS="true"
export ENABLE_HISTORY_SERVER="true"
```

By default, three workers are spawned when the chart is launched. Use the variable below to set the number of desired workers connected to the master host:

```shell
export WORKERS=3
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command
below to create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save
the expanded manifest file for future updates to your app.

```shell
helm template "${APP_INSTANCE_NAME}" chart/spark \
  --namespace "${NAMESPACE}" \
  --set spark.image.repo="${IMAGE_SPARK}" \
  --set spark.image.tag="${TAG}" \
  --set spark.persistence.storageClass="${STORAGE_CLASS}" \
  --set spark.persistence.size="${PERSISTENT_DISK_SIZE}" \
  --set spark.workers="${WORKERS}" \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
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

### Access to the Spark UI console

The deployed Service of Spark is of type ClusterIP, so you can reach
its web console from within a Kubernetes cluster by port-forwarding.
To do this, run the following commands:

```shell
# Forward the Spark UI web console's port to your local workspace
kubectl port-forward "svc/${APP_INSTANCE_NAME}-spark-master-svc" --namespace "${NAMESPACE}" 8080
```

Next, use your web browser to visit
[http://localhost:8080](http://localhost:8080) to view workers resources and applications running.

### Access to the Spark History UI console

If you want to check out the completed jobs, forward the History server port:

```shell
# Forward the Spark History console's port to your local workspace
kubectl port-forward "svc/${APP_INSTANCE_NAME}-spark-master-svc" --namespace "${NAMESPACE}" 18080
```

Next, use your web browser to visit
[http://localhost:18080](http://localhost:18080) to view the completed jobs, either successfully or not.

# Scaling

This is a master single-instance version of Spark. Workers can be scaled as many workers as your Cluster resources can handle, using the command below:

```shell
export REPLICAS=5
kubectl scale "deploy/${APP_INSTANCE_NAME}-spark-worker" --replicas "${REPLICAS}"
```

# Upgrade the app

## Prepare the environment

The steps below describe the upgrade procedure for the Docker image of Spark only.
They do not describe how to upgrade your Spark version.

> Note that during the upgrade, your Spark cluster will be unavailable.

Set your environment variables to match the installation properties:

```shell
export APP_INSTANCE_NAME=spark-1
export NAMESPACE=default
```

## Upgrade the app

The Spark StatefulSet and Deployments are configured to automatically roll out
updates as it receives them. To start this update process, scale down to 0 workers:

```shell
kubectl scale "deploy/${APP_INSTANCE_NAME}-spark-worker" --replicas 0
```

Then patch your workloads with the with a new image reference:

```shell
kubectl set image statefulset "${APP_INSTANCE_NAME}-spark-master" --namespace "${NAMESPACE}" spark="${NEW_IMAGE_REFERENCE}"
kubectl set image deployment "${APP_INSTANCE_NAME}-spark-worker" --namespace "${NAMESPACE}" spark="${NEW_IMAGE_REFERENCE}"
```

where `[NEW_IMAGE_REFERENCE]` is the Docker image reference of the
new image that you want to use.

To check the status of the Pods in the StatefulSet, and verify that
they are updating, run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=${APP_INSTANCE_NAME} --namespace "${NAMESPACE}" -w
```

The statefulset and deployment terminates each Pod, and waits for them to
transition to `Running`, and then `Ready`.

The final state of the Pods should be `Running`, with a value of
`1/1` in the **READY** column.

Once master pod is `Running` then scale the workers up back again:

```shell
kubectl scale "deploy/${APP_INSTANCE_NAME}-spark-worker" --replicas 3
```

To verify the current image being used for an `spark` container,
run the following command:

```shell
kubectl get statefulset "${APP_INSTANCE_NAME}-spark-master" \
  --namespace "${NAMESPACE}" \
  --output jsonpath='{.spec.template.spec.containers[0].image}'
```

# Uninstall the app

## Using the Google Cloud Console

1.  In the Cloud Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of apps, choose your app installation.

1.  On the Application Details page, click **Delete**.

## Using the command-line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=spark-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend using a `kubectl` version that is the same
> as the version of your cluster. Using the same version for `kubectl`
> and the cluster helps to avoid unforeseen issues.

#### Delete the deployment by using the generated manifest file

Run `kubectl` on the expanded manifest file:
> **WARNING:** This will also delete your `persistentVolumeClaim`
> for Spark, which means that you will lose all of your Spark
> configuration.

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace ${NAMESPACE}
```

#### Delete the deployment by deleting the application resource

If you don't have the expanded manifest file, delete the resources by using types
and a label:

```shell
kubectl delete application --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

### Delete the persistent volumes of your installation

By design, removing StatefulSets and Deployments in Kubernetes does not remove any
PersistentVolumeClaims that were attached to their Pods. This
prevents your installations from accidentally deleting stateful data.

To remove the PersistentVolumeClaims with their attached persistent disks, run
the following `kubectl` command:

```shell
kubectl delete persistentvolumeclaims \
  --namespace ${NAMESPACE}
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```
