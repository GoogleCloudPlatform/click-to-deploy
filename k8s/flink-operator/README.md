# Overview

Apache Flink is a framework and distributed processing engine for stateful
computations over unbounded and bounded data streams.

Flink Operator is a Kubernetes Custom Resource Definition (CRD) operator for
specifying and running Apache Flink apps idiomatically on Kubernetes.

Learn more about [Flink Operator](https://github.com/GoogleCloudPlatform/flink-on-k8s-operator).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Use Google Cloud Marketplace to install
the Flink Operator app to a Google Kubernetes Engine cluster. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/flink-operator).

## Command-line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation for the following instructions.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/flink-operator)

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [envsubst](https://command-not-found.com/envsubst)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command-line:

```shell
export CLUSTER=flink-operator-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and its associated tools repo:

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

### Install the app

Navigate to the `flink-operator` directory:

```shell
cd click-to-deploy/k8s/flink-operator
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=flink-operator
export NAMESPACE=flink-operator-system
```

Configure the container images:

```shell
TAG=v1beta1-4
export FLINK_OPERATOR_IMAGE="gcr.io/flink-operator/flink-operator:${TAG}"
export DEPLOYER_IMAGE="gcr.io/cloud-marketplace-tools/k8s/deployer_helm:0.8.0"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed app always uses the same images, until you are
ready to upgrade. To get the digest for an image, use the following script:

```shell
for i in "FLINK_OPERATOR_IMAGE"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```

#### Create namespace in your Kubernetes cluster

If you want to use a namespace other than `default`, create the new namespace by
running the command below:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Configure the service account

For the operator to be able to manipulate Kubernetes resources, there must be a
service account in the target namespace with cluster-wide permissions to
manipulate Kubernetes resources.

To provision a service account and export it via an environment variable, run the
following command:

```shell
export SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-sa"
export CRD_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-crd-creator-job"
```

To create service accounts, expand the manifest:

```shell
cat resources/service-accounts.yaml \
  | envsubst '${APP_INSTANCE_NAME} \
              ${NAMESPACE} \
              ${OPERATOR_SERVICE_ACCOUNT} \
              ${SERVICE_ACCOUNT} \
              ${CRD_SERVICE_ACCOUNT}' \
    > "${APP_INSTANCE_NAME}_sa_manifest.yaml"
```

You can create the accounts on the cluster with `kubectl`:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_sa_manifest.yaml" \
    --namespace "${NAMESPACE}"
```

#### Expand the manifest template

Use `envsubst` to expand the template. We recommend that you save the
expanded manifest file for future updates to the app.

```shell
awk 'FNR==1 {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $FLINK_OPERATOR_IMAGE $SERVICE_ACCOUNT $CRD_SERVICE_ACCOUNT $DEPLOYER_IMAGE' \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

To apply the manifest to your Kubernetes cluster, use `kubectl`:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View your app in the Google Cloud Console

To get the Cloud Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view your app, open the URL in your browser.

### Deploy your Flink apps

Follow these
[examples](https://github.com/GoogleCloudPlatform/flink-on-k8s-operator/blob/master/docs/user_guide.md#submit-a-job)
to deploy your Flink jobs.

# Back up and restore

## Back up Flink configuration data to your local environment

To back up Flink resources, use the following command:

```shell
export NAMESPACE=default
kubectl --namespace "${NAMESPACE}" get crd \
   flinkclusters.flinkoperator.k8s.io
   --output=yaml > backup_file.yaml
```

## Restore Flink configuration data from your local environment

To restore Flink resources from your local environment, use the following command:

```shell
kubectl --namespace "${NAMESPACE}" apply -f backup_file.yaml
```
