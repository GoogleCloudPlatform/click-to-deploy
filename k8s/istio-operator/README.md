# Overview

Istio Operator

For more information on Istio Operator, see the
[istio.io website](https://istio.io/).

## About Google Click to Deploy

Popular open source software stacks on Kubernetes packaged by Google and made
available in Google Cloud Marketplace.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Istio Operator to a Google
Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/istio-operator).

## Command line instructions

> **NOTE:** If desired, you can install the Istio Operator via the command line
> without using Google Cloud Marketplace by following the directions at
> [the official istio.io webpage](https://istio.io/latest/docs/setup/install/standalone-operator).
> If you would like to install via Google Cloud Marketplace, continue to the
> instructions below.

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/istio-operator)

### Prerequisites

#### Set up command line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your
environment by default.

-   [gcloud](https://cloud.google.com/sdk/gcloud/)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
-   [docker](https://docs.docker.com/install/)
-   [openssl](https://www.openssl.org/)
-   [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a cluster from the command line. If you already have a cluster that you
want to use, this step is optional.

```shell
export CLUSTER=istio-operator-cluster
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

To set up your cluster to understand Application resources, run the following
command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once for each cluster.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `istio-operator` directory:

```shell
cd click-to-deploy/k8s/istio-operator
```

#### Configure the app with environment variables

Choose an instance name and
[namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the Istio recommended defaults in the
example below.

```shell
export APP_INSTANCE_NAME=istio-operator-1
export OPERATOR_NAMESPACE=istio-operator
export ISTIO_NAMESPACE=istio-system
```

Create the operator namespace:

```shell
kubectl create namespace "${OPERATOR_NAMESPACE}"
```

Choose a name for the service account:

```shell
export ISTIO_SERVICE_ACCOUNT=istio-operator
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/istio-operator \
  --name "${APP_INSTANCE_NAME}" \
  --operatorNamespace "${OPERATOR_NAMESPACE}" \
  --istioNamespace "${ISTIO_NAMESPACE}" \
  --serviceAccountName "${ISTIO_SERVICE_ACCOUNT}" \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster.

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${OPERATOR_NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

# Deploy an instance of Istio

Run the following command to deploy a default Istio instance:

```shell
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: $ISTIO_NAMESPACE
  name: example-istiocontrolplane
spec:
  profile: default
EOF
```

Optionally, you can deploy the Istio instance to another namespace.

You can find additional information on different Istio profiles at the
[official Istio profile page](https://istio.io/latest/docs/setup/additional-setup/config-profiles/).
To see all of the features that Istio offers, you might consider installing the
"demo" profile and using the
[Istio example Bookinfo Application](https://istio.io/latest/docs/examples/bookinfo/)
to explore.

You can find other additional configuration options at the
[official Istio documentation page](https://istio.io/latest/docs/setup/install/standalone-operator/).

# Uninstall the operator

## Using the Google Cloud Console

1.  In the Cloud Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1.  From the list of apps, click **Istio**.

1.  On the Application Details page, click **Delete**.

## Using the command-line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=istio-operator-1
export OPERATOR_NAMESPACE=istio-operator
```

### Delete the resources

> **NOTE:** We recommend that you use a `kubectl` version that is the same
> version as that of your cluster. Using the same versions of `kubectl` and the
> cluster helps to avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace ${OPERATOR_NAMESPACE}
```

Otherwise, delete the resources by using types and a label:

```shell
kubectl delete application \
  --namespace ${OPERATOR_NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

> **NOTE:** This will delete only the `istio-operator` app. All
> `istio-operator`-managed resources will remain available.

### Delete the GKE cluster

Optionally, if you don't need the deployed app or the GKE cluster, delete the
cluster by using this command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```
