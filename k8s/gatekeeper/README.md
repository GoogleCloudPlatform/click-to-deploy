# Overview

Gatekeeper is a customizable admission webhook for Kubernetes that enforces policies executed by the [Open Policy Agent](https://www.openpolicyagent.org). 

Please be aware that Gatekeeper is in beta status. In addition, this installation guide relies on staging deployer images.

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Gatekeeper app to a Google
Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/gatekeeper).

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

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=gatekeeper-cluster
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

Navigate to the `gatekeeper` directory:

```shell
cd click-to-deploy/k8s/gatekeeper
```

#### Configure the app with environment variables

Please use the following for the instance name and [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) for the app.

```shell
export APP_INSTANCE_NAME=gatekeeper
export NAMESPACE=gatekeeper-system
```

Define the audit interval, in seconds. The default value is 60.
```shell
export AUDIT_INTERVAL=60
```

Configure the container image:

```shell
TAG=3.0
export IMAGE_GATEKEEPER="gcr.io/gatekeeper-marketplace/gatekeeper:${TAG}"
```

The image above is referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin the image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images, until
you are ready to upgrade. To get the digest for the image, use the following
script:

```shell
i="IMAGE_GATEKEEPER"
repo=$(echo ${!i} | cut -d: -f1);
digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
export $i="$repo@$digest";
env | grep $i;
```

#### Create namespace in your Kubernetes cluster

Run the command below to create the new namespace:

```shell
kubectl create namespace "$NAMESPACE"
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/gatekeeper \
  --name $APP_INSTANCE_NAME \
  --namespace $NAMESPACE \
  --set gatekeeper.imageGatekeeperRepo=gcr.io/gatekeeper-marketplace/gatekeeper \
  --set gatekeeper.imageGatekeeperTag=$TAG \
  --set gatekeeper.auditInterval=$AUDIT_INTERVAL > "${APP_INSTANCE_NAME}_manifest.yaml"
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

To view the app, open the URL in your browser.

### Scaling

Gatekeeper is a single-instance application; it is not intended to be scaled up.

# Uninstall the Application

## Using the Google Cloud Platform Console

1.  In the GCP Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1.  From the list of applications, click **Gatekeeper**.

1.  On the Application Details page, click **Delete**.

## Using the command line

Run the following to uninstall Gatekeeper:

   * cd to the Gatekeeper directory
   * run `make app/uninstall`

### Manually Removing Constraints

If Gatekeeper is no longer running and there are extra constraints in the cluster, then the finalizers, CRDs and other artifacts must be removed manually:

   * Delete all instances of the constraint resource
   * Executing `kubectl patch  crd constrainttemplates.templates.gatekeeper.sh -p '{"metadata":{"finalizers":[]}}' --type=merge`. Note that this will remove all finalizers on every CRD. If this is not something you want to do, the finalizers must be removed individually.
   * Delete the `CRD` and `ConstraintTemplate` resources associated with the unwanted constraint.