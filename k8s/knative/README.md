# Overview

Knative is an Open-Source Enterprise-level solution to build Serverless and Event Driven Applications

For more information, visit the Knative [official website](https://knative.dev/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

![Architecture diagram](resources/knative-k8s-app-architecture.png)

This app offers "list of resources".

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! To install this Cert Manager app to a
Google Kubernetes Engine cluster via Google Cloud Marketplace, follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/cert-manager).

## Command-line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, then `gcloud`, `kubectl`, Docker, and Git are installed in
your environment by default.

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [helm](https://helm.sh/)
- [envsubst](https://command-not-found.com/envsubst)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine (GKE) cluster

Create a new cluster from the command-line:

```shell
export CLUSTER=cert-manager-cluster
export ZONE=us-west1-a

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
community. You can find the source code at
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the app

Navigate to the `knative` directory:

```shell
cd click-to-deploy/k8s/knative
```

#### Configure the app with environment variables

Set up the image tag:

It is advised to use a stable image reference, which you can find on:
- [Cert Manager - Marketplace Container Registry](https://marketplace.gcr.io/google/cert-manager1).
- [Knative - Marketplace Container Registry](https://marketplace.gcr.io/google/knative1).
- [Istio - Docker Hub](https://hub.docker.com/r/istio/proxyv2/tags)
For example:

```shell
TRACK_CERT_MANAGER=1.6
TRACK_ISTIO=1.13.0
TRACK_KNATIVE=v1.3.0
```

Configure the container images:

```shell
# CERT MANAGER
IMAGE_CERT_MANAGER=marketplace.gcr.io/google/cert-manager1

# ISTIO
IMAGE_ISTIO_INGRESSGATEWAY=docker.io/istio/proxyv2
IMAGE_ISTIO_ISTIOD=docker.io/istio/pilot

# KNATIVE SERVING
IMAGE_KNATIVE_SERVING_ACTIVATOR=gcr.io/knative-releases/knative.dev/serving/cmd/activator
IMAGE_KNATIVE_SERVING_AUTOSCALER=gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler
IMAGE_KNATIVE_SERVING_CONTROLLER=gcr.io/knative-releases/knative.dev/serving/cmd/controller
IMAGE_KNATIVE_SERVING_DOMAINMAPPING=gcr.io/knative-releases/knative.dev/serving/cmd/domain-mapping
IMAGE_KNATIVE_SERVING_DOMAINMAPPING_WEBHOOK=gcr.io/knative-releases/knative.dev/serving/cmd/domain-mapping-webhook
IMAGE_KNATIVE_SERVING_QUEUEPROXY=gcr.io/knative-releases/knative.dev/serving/cmd/queue
IMAGE_KNATIVE_SERVING_WEBHOOK=gcr.io/knative-releases/knative.dev/serving/cmd/webhook
IMAGE_KNATIVE_SERVING_NETCERMANAGER_CONTROLLER=gcr.io/knative-releases/knative.dev/net-certmanager/cmd/controller
IMAGE_KNATIVE_SERVING_NETCERMANAGER_WEBHOOK=gcr.io/knative-releases/knative.dev/net-certmanager/cmd/webhook
IMAGE_KNATIVE_SERVING_NETISTIO_CONTROLLER=gcr.io/knative-releases/knative.dev/net-istio/cmd/controller
IMAGE_KNATIVE_SERVING_NETISTIO_WEBHOOK=gcr.io/knative-releases/knative.dev/net-istio/cmd/webhook

# KNATIVE EVENTING
IMAGE_KNATIVE_EVENTING_CONTROLLER=gcr.io/knative-releases/knative.dev/eventing/cmd/controller
IMAGE_KNATIVE_EVENTING_MTPING=gcr.io/knative-releases/knative.dev/eventing/cmd/mtping
IMAGE_KNATIVE_EVENTING_WEBHOOK=gcr.io/knative-releases/knative.dev/eventing/cmd/webhook
```

By default, each deployment has 1 replica, but you can choose to set the
number of replicas for:
- Cert Manager controller, webhook and cainjector.
- Istio ingress gateway.
- Knative autoscaler.

```shell
export CERT_MANAGER_CONTROLLER_REPLICAS=3
export CERT_MANAGER_WEBHOOK_REPLICAS=3
export CERT_MANAGER_CAINJECTOR_REPLICAS=3
export ISTIO_INGRESS_GATEWAY_REPLICAS=3
export KNATIVE_AUTOSCALER_REPLICAS=3
```
