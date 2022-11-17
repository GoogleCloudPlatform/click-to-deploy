# Overview

Argo Workflows is an open source container-native workflow engine for orchestrating parallel jobs on Kubernetes.
It is implemented as a Kubernetes CRD (Custom Resource Definition).

Define workflows where each step in the workflow is a container.
Model multi-step workflows as a sequence of tasks or capture the dependencies between tasks using a directed acyclic graph (DAG).

It can run intensive jobs for machine learning or data processing in a fraction of the time using Argo Workflows on Kubernetes.

For more information, visit the Argo Workflows
[official website](https://argoproj.github.io/argo-workflows/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

![Architecture diagram](resources/argoworkflows-k8s-app-architecture.png)

By default, Argo Workflows Server UI is exposed using a ClusterIP Service on port 2746.

Separate Deployment, StatefulSets Kubernetes objects are used to manage the Argo Workflow Controller and PostgreSQL instances.

A single instance of each Argo Workflows component is deployed as a single Pod,
using a Kubernetes StatefulSet for PostgreSQL and a Deployment for Server and Controller.

The Server instance connects to PostgreSQL over port `5432`. The
application data is stored in the `argo_workflows` database. A single instance of PostgreSQL is deployed
as a Pod, using a Kubernetes StatefulSet.

PostgreSQL credentials are stored in the `[APP_INSTANCE_NAME]-postgresql-secret`
Secret resource.

*   The username and password required to access the `argo_workflows` database are stored in
    the `db-user` and `db-password` Secrets, respectively.


# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Argo Workflows app to a Google Kubernetes Engine cluster in Google Cloud Marketplace by following these [on-screen instructions](https://console.cloud.google.com/marketplace/details/google/argo-workflows).

## Command line instructions

### Prerequisites

#### Set up command line tools

You'll need the following tools in your development environment. If you're using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your environment by default.

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [jq](https://stedolan.github.io/jq/download/)
- [yaml2json](https://github.com/bronze1man/yaml2json)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=argo-workflows-cluster
export ZONE=us-west1-a

gcloud container clusters create "${CLUSTER}" --zone "${ZONE}"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}"
```

#### Clone this repo

Clone this repo, as well as the associated tools repo:

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

You need to run this command once.

The Application resource is defined by the [Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps) community. The source code can be found on [github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the app

Navigate to the `argo-workflows` directory:

```shell
cd click-to-deploy/k8s/argo-workflows
```

#### Configure the app with environment variables

Choose an instance name and [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=argo-workflows-1
export NAMESPACE=default
```

For the persistent disk provisioning of the Deployments and StatefulSets, you will need to:

 * Set the StorageClass name. Check your available options using the command below:
   * ```kubectl get storageclass```
   * Or check how to create a new StorageClass in [Kubernetes Documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#the-storageclass-resource)

 * Set the persistent disk's size. The default disk size for MySQL is "8Gi" and for redis is "5Gi".

```shell
export DEFAULT_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export PERSISTENT_DISK_SIZE="10Gi"
```

(Optional) Enable Stackdriver Metrics Exporter:

> **NOTE:** Your GCP project must have Stackdriver enabled. If you are using a
> non-GCP cluster, you cannot export metrics to Stackdriver.

By default, the app does not export metrics to Stackdriver. To enable this option, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=false
```

Set up the image tag:

It is advised to use stable image reference which you can find on
[Marketplace Container Registry](https://marketplace.gcr.io/google/argo-workflows).
Example:

```shell
export TAG="<BUILD_ID>"
```

Alternatively you can use short tag which points to the latest image for selected version.
> Warning: this tag is not stable and referenced image might change over time.

```shell
export TAG="3.4"
```

Configure the container images:

```shell
export IMAGE_REGISTRY="marketplace.gcr.io/google"

export IMAGE_ARGO_WORKFLOWS="${IMAGE_REGISTRY}/argo-workflows"
export IMAGE_POSTGRESQL="${IMAGE_ARGO_WORKFLOWS}/postgresql:${TAG}"
export IMAGE_POSTGRESQL_EXPORTER="${IMAGE_ARGO_WORKFLOWS}/postgresql-exporter:${TAG}"
export IMAGE_METRICS_EXPORTER="${IMAGE_ARGO_WORKFLOWS}/prometheus-to-sd:${TAG}"
```

Set or generate the passwords:

```shell
# Set postgresql argo password
export DB_USER_PASSWORD="argo_db_password"
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Create the Argo Workflows Service Accounts

To create the Argo Workflows Service Accounts:

```shell
export ARGO_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-argo"
export ARGO_SERVER_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-argoserver"

kubectl create serviceaccount "${ARGO_SERVICE_ACCOUNT}" --namespace "${NAMESPACE}"
```

#### Install the Argo Workflows CRDs

To install them, run:

```shell
resources/install-crd.sh
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template "${APP_INSTANCE_NAME}" chart/argo-workflows \
    --namespace "${NAMESPACE}" \
    --set argo_workflows.image.repo="${IMAGE_ARGO_WORKFLOWS}" \
    --set argo_workflows.image.tag="${TAG}" \
    --set argo_workflows.db.password="${DB_USER_PASSWORD}" \
    --set argo_workflows.sa.server="${ARGO_SERVER_SERVICE_ACCOUNT}" \
    --set argo_workflows.sa.argo="${ARGO_SERVICE_ACCOUNT}" \
    --set db.image="${IMAGE_POSTGRESQL}" \
    --set db.exporter.image="${IMAGE_POSTGRESQL_EXPORTER}" \
    --set db.persistence.size="${PERSISTENT_DISK_SIZE}" \
    --set persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
    --set metrics.image="${IMAGE_METRICS_EXPORTER}" \
    --set metrics.exporter.enabled="${METRICS_EXPORTER_ENABLED}" \
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
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

### Accessing Argo Workflows Server UI

As authentication is done by the Kubernetes cluster, connection is private,
use port-forwarding (`kubectl port-forward`) in order to connect to the UI.

Run the following command in the background:

```shell
kubectl port-forward \
  --namespace ${NAMESPACE} \
  svc/argo-server \
  2746:2746
```

Now you can access the Argo Workflows Server UI [https://localhost:2746](https://localhost:2746)


# App metrics

## Prometheus metrics

The app can be configured to expose its metrics through the [MySQL Server Exporter](https://github.com/GoogleCloudPlatform/mysql-docker/tree/master/exporter), and [Redis Exporter](https://github.com/GoogleCloudPlatform/redis-docker/tree/master/exporter), in the [Prometheus format](https://github.com/prometheus/docs/blob/master/content/docs/instrumenting/exposition_formats.md).

1.  You can access the Redis metrics at `[REDIS-SERVICE]:9121/metrics`, where `[REDIS-SERVICE]` is the
    [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/) `${APP_INSTANCE_NAME}-redis-svc`.

2.  You can access the MySQL metrics at `[MYSQL-SERVICE]:9104/metrics`, where `[MYSQL-SERVICE]` is the
    [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/) `${APP_INSTANCE_NAME}-mysql-svc`.

### Configuring Prometheus to collect the metrics

Prometheus can be configured to automatically collect the app's metrics. Follow the steps in [Configuring Prometheus](https://prometheus.io/docs/introduction/first_steps/#configuring-prometheus).

You configure the metrics in the [`scrape_configs` section](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config).

## Exporting metrics to Stackdriver

The deployment includes a [Prometheus to Stackdriver (`prometheus-to-sd`)](https://github.com/GoogleCloudPlatform/k8s-stackdriver/tree/master/prometheus-to-sd) container. If you enabled the option to export metrics to Stackdriver, the metrics are exported to Stackdriver automatically, and visible in [Stackdriver Metrics Explorer](https://cloud.google.com/monitoring/charts/metrics-explorer).

The name of each metric starts with the component's name (`redis` for Redis Server and `mysql` for MySQL)
Metrics are labeled with `app.kubernetes.io/name`, which includes the app's name as defined in the `APP_INSTANCE_NAME` environment variable.

The export option may not be available for GKE on-prem clusters.

> Note: Stackdriver has [quotas](https://cloud.google.com/monitoring/quotas) for
> the number of custom metrics created in a single GCP project. If the quota is
> met, additional metrics might not show up in the Stackdriver Metrics Explorer.

To remove existing metric descriptors, use [Stackdriver's REST API](https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.metricDescriptors/delete).

### Scaling

#### Scaling the cluster up or down

Argo Workflows Controllers can be easily scaled up or down.

By default, the cluster is deployed with a single replica. To
change the number of replicas, use the following command, where
`REPLICAS` sets the desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deploy "${APP_INSTANCE_NAME}-controller" \
  --namespace "${NAMESPACE}" --replicas="${REPLICAS}"
```

If you want to scale your app down, use this command to reduce the
number of replicas, which disconnects nodes from the cluster.
Scaling down does not affect your Deployments's
`PersistentVolumeClaims`.

# Upgrading the app

Start by assigning a new image to your Deployment,StatefulSet or DaemonSet definition:

```shell
kubectl set image deployment "$APP_INSTANCE_NAME-server" \
  --namespace "$NAMESPACE" manager=[NEW_IMAGE_REFERENCE]
```

where `[NEW_IMAGE_REFERENCE]` is the new image.

To check that the Pods in the Deployment running the `server` container are
updating, run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME --namespace "$NAMESPACE" -w
```

The controller terminates each Pod, and waits for it to transition
to `Running` and `Ready` before updating the next Pod.

The final state of the Pods should be `Running`, with a value of `1/1` in the
**READY** column.

To verify the current image used for a `server` container, run the following
command:

```shell
kubectl get statefulsets "$APP_INSTANCE_NAME-server" \
  --namespace "$NAMESPACE" \
  --output jsonpath='{.spec.template.spec.containers[0].image}'
```


# Uninstall the app

## Using the Google Cloud Console

1. In the Cloud Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

2. From the list of apps, select **argo-workflows**.

3. On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=argo-workflows-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend to use a kubectl version that is the same as the version of your cluster. Using the same versions of kubectl and the cluster helps avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

Alternately, you can delete the resources by using types and a label:

```shell
kubectl delete application \
  --namespace "${NAMESPACE}" \
  --selector "app.kubernetes.io/name=${APP_INSTANCE_NAME}"
```

### Delete the persistent volumes of your installation

By design, the removal of StatefulSets in Kubernetes does not remove the PersistentVolumeClaims that were attached to their Pods. This prevents your installations from accidentally deleting stateful data.

To remove the PersistentVolumeClaims along with their attached persistent disks, run the following `kubectl` commands:

```shell
# specify the variables values matching your installation:
export APP_INSTANCE_NAME=argo-workflows-1
export NAMESPACE=default

kubectl delete persistentvolumeclaims \
  --namespace "${NAMESPACE}" \
  --selector "app.kubernetes.io/name=${APP_INSTANCE_NAME}"
```

### Delete the GKE cluster

Optionally, if you no longer need the deployed app or the GKE cluster to which it is deployed, you can delete the cluster by running the following command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```
