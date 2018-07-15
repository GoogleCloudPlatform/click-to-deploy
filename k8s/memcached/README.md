# Overview

Memcached is an open source in-memory, key-value store. Key features of this solution include high performance and ease of distribution.
Although Memcached is intended to be use with dynamic web applications, it can be used as a caching system for a number of databases.

If you would like to learn more about Memcached, please, visit [Memcached website](https://memcached.org/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Memcached app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/memcached).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [pip](https://pip.pypa.io/en/stable/installing/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command-line.

```shell
export CLUSTER=marketplace-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to talk to the new cluster.

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo.

```shell
gcloud source repos clone google-click-to-deploy --project=k8s-marketplace-eap
gcloud source repos clone google-marketplace-k8s-app-tools --project=k8s-marketplace-eap
```

#### Install the Application resource definition

Do a one-time setup for your cluster to understand Application resource via installing Application's Custom Resource Definition.

<!--
To do that, navigate to `k8s/vendor` subdirectory of the repository and run the following command:
-->

```shell
kubectl apply -f google-marketplace-k8s-app-tools/crd/*
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

Specify the number of nodes for Memcached solution:
```shell
export REPLICAS=3
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
repo=`echo $IMAGE_MEMCACHED | cut -d: -f1`;
digest=`docker pull $IMAGE_MEMCACHED | sed -n -e 's/Digest: //p'`;
export $i="$repo@$digest";
env | grep $i;
```

#### Expand the manifest template

Use `envsubst` to expand the template. It is recommended that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_MEMCACHED $REPLICAS' \
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

Usually, there are two steps necessary to be able to use Memcache cluster

1. One needs to acquire IP addresses of servers running with Memcached cluster.

2. One needs to configure an application so it can use Memcached cluster as a cache. Usually, applications use specialized memcached clients (e.g. [pymemcache](http://pymemcache.readthedocs.io/en/latest/getting_started.html)) to run a hashing algorithm that is responsible for making selection which Memcached server to use for storing/retrieving cached data.

## Acquire IP addresses of Memcached instances

Your application can retrieve information about Memcached instances using kubectl command or pragmatically (e.g. via Python).

To discover IP addresses of Memcached instances using kubectl, please, run the following command:

```shell
kubectl get pods -o wide -l app.kubernetes.io/name=$APP_INSTANCE_NAME
```

To discover IP addresses of Memcached instances using Python you can use kubernetes module.

Use this command to install kubernetes module on your computer
```shell
pip install kubernetes
```

Here is an examplary code that could be used as a starting for ar Python program to discover Memcached IP addresses:

```python
import os
# if kubernetes module is not installed, please, install it, e.g. pip install kubernetes
from kubernetes import client, config
# Load Kube config
config.load_kube_config()
# Create a Kubernetes client
k8s_client = client.CoreV1Api()
# Get the list of all pods
pod_list = k8s_client.list_namespaced_pod("default")
# list all pods from the default namespace
for pod in pod_list.items:
    print("%s\t%s\t%s" % (pod.metadata.name, pod.status.phase, pod.status.pod_ip))
```

For more information about using Python to manage & discover Kubernetes cluster information, please, go to this page: https://github.com/kubernetes-client/python

## Using Memcached instances as a cache in your application
There are many memcached clients that potentially could be used for getting access to Memcached servers running in the cluster. Python pymemcache client is one of them. Please, refer to this documentation
http://pymemcache.readthedocs.io/en/latest/getting_started.html if you wold like to learn more about it.

## Exposure of Memcached service to external world

It is not recommended to expose Memcached K8s App for external access.

In this specific example, there is no encyption between an application and Memcached instances and no authentication/authorization schema is applied. The assumption is that applications deployed within the same Kubernetes cluster can talk freely to Memcached instances which are meant to be an internal cache of an application.

# Scaling

You can manually scale it up or down to deploy Memcached solution with desired number of replicas using the following command.

```shell
kubectl scale statefulsets "$APP_INSTANCE_NAME-memcached" --namespace "$NAMESPACE" --replicas=<new-replicas>
```

where `<new_replicas>` defines the new desired number.

# Backup and Restore

There is no need to backup Memcached application - it's due to the nature of Memcached which serves as internal application cache and is updated by application in a dynamic way.

# Update

This procudure assumes that you have a new image for memcached container published and being available to your Kubernetes cluster. The new image is available at <url-pointing-to-new-image>.

Start with modification of the image used for pod temaplate within Memcached StatefulSet:

```shell
kubectl set image statefulset "$APP_INSTANCE_NAME-memcached" \
  memcached=<url-pointing-to-new-image>
```

where `<url-pointing-to-new-image>` is the new image.

To check the status of Pods in the StatefulSet and the progress of deployment of new image run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME
```

To check the current image used by pods within `Memcached` K8s application, you can run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' | sort
```

# Deletion

You can uninstall/delete Memcached application either using Google Cloud Console or using K8s Apps tools.

* Navigate to the `memcached` directory.

```shell
cd google-click-to-deploy/k8s/memcached
```

* Expand the manifest template

Use `envsubst` to expand the template. It is recommended that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_MEMCACHED $REPLICAS' \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

* Run the uninstall command

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

Optionally, if you don't need both the deployed application and GKE cluster used for deployment then you can delete the whole GKE cluster using this command:

```shell
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```

# Logging and Monitoring

To set up logging for Memcached solution using Stackdriver, please, follow the instructuction decomented here: https://kubernetes.io/docs/tasks/debug-application-cluster/logging-stackdriver/#verifying-your-logging-agent-deployment
