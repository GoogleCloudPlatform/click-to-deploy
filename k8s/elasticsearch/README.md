# Overview

Elasticsearch is an open-source search engine that provides a distributed, multitenant-capable
full-text search engine with an HTTP web interface and schema-free JSON documents..

[Learn more](https://www.elastic.co/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Elasticsearch app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/elasticsearch).

## Command line instructions

### Prerequisites

#### Create a Google Kubernetes Engine cluster

You can use [gcloud](https://cloud.google.com/sdk/gcloud/) to create a new
cluster from the command line.

```shell
export CLUSTER_NAME=marketplace-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER_NAME" --zone "$ZONE"
```

#### Install the Application resource definition

Do a one-time setup for your cluster to understand Application resources.

```shell
kubectl apply -f k8s/vendor/marketplace-tools/crd/*
```

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Clone this repo

Clone this repo and initialize the git submodules.

```shell
git clone git@github.com:GoogleCloudPlatform/click-to-deploy.git
cd click-to-deploy
git submodule update --recursive --init
```

### Install the Application

Set environment variables to determine where the app should be installed.

```shell
export APP_INSTANCE_NAME=elasticsearch-1
export NAMESPACE=default
```

Set environment variables for the app container images.

```shell
export IMAGE_ELASTICSEARCH="marketplace.gcr.io/google/elasticsearch:latest"
```

Expand manifest template and run `kubectl apply`:

```
cd k8s/elasticsearch

awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst \
  | kubectl apply -f - --namespace "$NAMESPACE"
```
