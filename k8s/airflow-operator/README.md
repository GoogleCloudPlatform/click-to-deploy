# Overview

Airflow Operator is a custom Kubernetes operator that makes it easy to deploy
and manage Apache Airflow on Kubernetes. Apache Airflow is a platform to
programmatically author, schedule, and monitor workflows. Using the Airflow
Operator, an Airflow cluster is split into 2 parts, represented by the
AirflowBase and AirflowCluster
[custom resources](https://kubernetes.io/docs/tasks/access-kubernetes-api/extend-api-custom-resource-definitions/).

The Airflow Operator performs these jobs:

1.  Creates and manages the Kubernetes resources for an Airflow deployment.
2.  Updates the corresponding Kubernetes resources when the AirflowBase or
    AirflowCluster specification changes.
3.  Restores managed Kubernetes resources that are deleted.
4.  Supports creation of different kinds of Airflow schedulers.
5.  Supports multiple AirflowClusters per AirflowBase.

Learn more about the [Airflow](https://airflow.apache.org/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install Airflow Operator app to a Google
Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/airflow-operator).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/airflow-operator)

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, `gcloud`, `kubectl`, Docker and Git are installed on your
environment by default.

-   [gcloud](https://cloud.google.com/sdk/gcloud/)
-   [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
-   [docker](https://docs.docker.com/install/)
-   [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=airflow-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Clone this repo

Clone this repo and the associated tools repo.

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

Navigate to the `airflow-operator` directory.

```shell
cd click-to-deploy/k8s/airflow-operator
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=airflow-operator-1
export NAMESPACE=default
```

Configure the container images:

```shell
TAG=alpha
export IMAGE_AIRFLOWOPERATOR="marketplace.gcr.io/google/airflow-operator:${TAG}"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images, until
you are ready to upgrade. To get the digest for the image, use the following
script:

```shell
for i in "IMAGE_AIRFLOWOPERATOR"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to
create a new namespace:

```shell
kubectl create namespace "$NAMESPACE"
```

#### Configure the service account

The operator needs a service account in the target namespace with cluster wide
permissions to manipulate Kubernetes resources.

Provision a service account and export its via an environment variable as
follows:

```shell
kubectl create serviceaccount "${APP_INSTANCE_NAME}-sa" --namespace "${NAMESPACE}"
kubectl create clusterrolebinding "${NAMESPACE}-${APP_INSTANCE_NAME}-sa-rb" --clusterrole=cluster-admin --serviceaccount="${NAMESPACE}:${APP_INSTANCE_NAME}-sa"
export SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-sa"
```

#### Expand the manifest template

Use `envsubst` to expand the template. We recommend that you save the expanded
manifest file for future updates to the application.

```shell
awk 'FNR==1 {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_AIRFLOWOPERATOR
  $SERVICE_ACCOUNT' \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view your app, open the URL in your browser.

# Using Airflow Operator

To deploy an Airflow cluster, we need to create the AirflowBase resource first
followed by AirflowCluster resource.

```
# create AirflowBase resource first
$ kubectl apply -f - <<EOF
apiVersion: airflow.k8s.io/v1alpha1
kind: AirflowBase
metadata:
  name: mc-base
spec:
  mysql:
    operator: False
EOF

# get status of the CRs
$ kubectl get airflowbase/mc-base -o yaml

# after 30-60s deploy cluster components
# create AirflowCluster resource next
$ kubectl apply -f - <<EOF
apiVersion: airflow.k8s.io/v1alpha1
kind: AirflowCluster
metadata:
  name: mc-cluster
spec:
  executor: Celery
  redis:
    operator: False
  scheduler:
    version: "1.10.0rc2"
  ui:
    replicas: 1
  worker:
    replicas: 2
  dags:
    subdir: "airflow/example_dags/"
    git:
      repo: "https://github.com/apache/incubator-airflow/"
      once: true
  airflowbase:
    name: mc-base
EOF

# get status of the cluster
$ kubectl get airflowcluster/mc-cluster -o yaml

# after 30-60s deploy port forward to access UI
# access UI by pointing browser to localhost:8080
$ kubectl port-forward mc-cluster-airflowui-0 8080:8080
```

# Uninstall the Application

## Using the Google Cloud Platform Console

1.  In the GCP Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1.  From the list of applications, click **Airflow Operator**.

1.  On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=airflow-operator-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend to use a kubectl version that is the same as the
> version of your cluster. Using the same versions of kubectl and the cluster
> helps avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

Otherwise, delete the resources using types and a label:

```shell
kubectl delete application,deployment\
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete the GKE cluster

Optionally, if you don't need the deployed application or the GKE cluster,
delete the cluster using this command:

```
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```
