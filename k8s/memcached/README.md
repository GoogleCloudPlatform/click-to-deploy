# Overview
Memcached is an open source in-memory, key-value store. Key features of this solution include high performance and ease of distribution.
Although Memcached is intended to be use with dynamic web applications, it can be used as a caching system for a number of databases.

If you would like to learn more about Memcached, please, visit [Memcached website](https://memcached.org/).

## About Google Click to Deploy K8s Solutions

Popular open source software stacks on Kubernetes packaged by Google and made available in Google Cloud Marketplace.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Memcached app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/memcached1).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command-line.

```shell
export CLUSTER=marketplace-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to talk to the new cluster.

```shell
gcloud container clusters get-credentials "$CLUSTER"
```

#### Clone this repo

Clone this repo and the associated tools repo.

```shell
gcloud source repos clone google-click-to-deploy --project=k8s-marketplace-eap
gcloud source repos clone google-marketplace-k8s-app-tools --project=k8s-marketplace-eap
```

#### Install the Application resource definition

Do a one-time setup of your cluster and install Custom Reference Definition object for Kubernetes Application.

To do that, please, navidate to k8s/vendor subfolder of click-to-deploy repository and run the following command:

```shell
kubectl apply -f marketplace-tools/crd/*
```

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `memcached` directory.

```shell
cd google-click-to-deploy/k8s/memcached
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export APP_INSTANCE_NAME=memcached-1
export NAMESPACE=default
```

Configure the container images.

```shell
export IMAGE_MEMCACHED="gcr.io/k8s-marketplace-eap/google/memcached:latest"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
for i in "IMAGE_MEMCACHED"; do
  repo=`echo ${!i} | cut -d: -f1`;
  digest=`docker pull ${!i} | sed -n -e 's/Digest: //p'`;
  export $i="$repo@$digest";
  env | grep $i;
done
```

#### Expand the manifest template

Use `envsubst` to expand the template. It is recommended that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_MEMCACHED $IMAGE_INIT' \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply to Kubernetes

Use `kubectl` to apply the manifest to your Kubernetes cluster.

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

Point your browser to:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

# Basic Usage

*TODO: instructions to be written *

## Acquire IP addresses of Memcached instances

Your application can retrieve information about Memcached instances using kubectl command or pragmatically (e.g. via Python).

To discover IP addresses of Memcached instances using kubectl, please, run the following command:

```shell
kubectl get pods -o wide -l app.kubernetes.io/name=$APP_INSTANCE_NAME
```

To discover IP addresses of Memcached instances using Python, please, use this code:

```shell
TO BE DELIVERED
```

## Expose Memcached service to external world

In this specific example, there is no encyption between an application and Memcached instances and no authentication/authorization schema is applied. The assumption is that applications deployed within the same Kubernetes cluster can talk freely to Memcached instances which are meant to be an internal cache of an application. 

It is not recommended to expose Memcached K8s App for external access.

# Scaling

By default, Memcached K8s application is deployed using 2 replicas. You can manually scale it up or down to deploy Memcached solution with desired number of replicas using the following command.

```shell
kubectl scale statefulsets "$APP_INSTANCE_NAME-memcached" --namespace "$NAMESPACE" --replicas=<new-replicas>
```

where <new_replicas> defines the number of replicas.

# Backup and Restore

There is no need to backup Memcached application - it's due to the nature of Memcached which serves as internal application cache and is updated by application in a dynamic way. 

# Memcached updates

*TODO: instructions for upgrades*

# Deletion

You can uninstall/delete Memcached application either using Google Cloud Console or using K8s Apps tools.

* Navigate to the `memcached` directory.

```shell
cd google-click-to-deploy/k8s/memcached
```
* Run the uninstall command

```shell
make app/uninstall
```

Optionally, if you don't need both the deployed application and GKE cluster used for deployment then you can delete the whole GKE cluster using this command:

```shell
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```

# Logging and Monitoring

To set up logging for Memcached solution using Stackdriver, please, follow the instructuction decomented here: https://kubernetes.io/docs/tasks/debug-application-cluster/logging-stackdriver/#verifying-your-logging-agent-deployment
