# Overview

Memcached is an open source in-memory key-value store. The key features of this solution include high performance and ease of distribution.
Although Memcached is intended to be use with dynamic web applications, it can be used as a caching system for a number of databases.

To learn more about Memcached, visit the [Memcached website](https://memcached.org/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

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

Create a new cluster from the command line.

```shell
export CLUSTER=memcached-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to connect to the new cluster.

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

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

Set up your cluster to understand Application resources, navigate to `k8s/vendor`
folder in the repository and run the following command:

```shell
kubectl apply -f google-marketplace-k8s-app-tools/crd/*
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `memcached` directory:

```shell
cd google-click-to-deploy/k8s/memcached
```

#### Configure the app with environment variables

Choose an instance name and namespace for the app. You typically use
[namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
if you have many users spread across multiple teams or projects.


```shell
export APP_INSTANCE_NAME=memcached-1
export NAMESPACE=default
```

Set the number of replicas:
```shell
export REPLICAS=3
```

Configure the container image:

```shell
export IMAGE_MEMCACHED="gcr.io/k8s-marketplace-eap/google/memcached:latest"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images,
until you are ready to upgrade. To get the digest for the image, use the
following script:

```shell
repo=`echo $IMAGE_MEMCACHED | cut -d: -f1`;
digest=`docker pull $IMAGE_MEMCACHED | sed -n -e 's/Digest: //p'`;
export $i="$repo@$digest";
env | grep $i;
```

#### Expand the manifest template

Use `envsubst` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_MEMCACHED $REPLICAS' \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster.

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Platform Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view your app, open the URL in your browser.

# Using the Memcached app

1. Get the external IP address for the Memcached cluster.

2. Configure your application to use the Memcached cluster as a cache.
   Typically, applications use specialized Memcached clients, such as
   [pymemcache](http://pymemcache.readthedocs.io/en/latest/getting_started.html).
   The clients run a hashing algorithm to select a Memcached server
   for storing or retrieving cached data.

## Get the IP addresses of your Memcached instances

Your application can get information about Memcached instances using the
`kubectl` command, or programmatically.

To get the IP addresses of your Memcached instances using `kubectl`, run the
following command:

```shell
kubectl get pods -o wide -l app.kubernetes.io/name=$APP_INSTANCE_NAME
```

To get the IP addresses of your Memcached instances using Python, you can use
the `kubernetes` module.

To install the `kubernetes` module, run the following command:
```shell
pip install kubernetes
```

Sample Python code to get the IP addresses:

```python
import os

# kubernetes module; install with `pip install kubernetes`
from kubernetes import client, config

# Load Kubernetes config
config.load_kube_config()

# Create a Kubernetes client
k8s_client = client.CoreV1Api()

# Get the list of all pods
pod_list = k8s_client.list_namespaced_pod("default")

# list all pods from the default namespace
for pod in pod_list.items:
    print("%s\t%s\t%s" % (pod.metadata.name, pod.status.phase, pod.status.pod_ip))
```

For more information about using the `kubernetes` module, see
https://github.com/kubernetes-client/python

## Using Memcached instances as a cache in your application

You can use one of many Memcached clients to access your Memcached cluster,
such as `pymemcache`. For information on `pymemcache`, see http://pymemcache.readthedocs.io/en/latest/getting_started.html.

## Note about exposing the Memcached service externally

Avoid exposing your Memcached service externally. Applications in the same
Kubernetes cluster can access your Memcached instances.

Additionally, in this specific example, there is no encyption between
applications and the Memcached instances, and no authentication/authorization
schema is applied.

# Scaling

You can scale your Memcached service up or down by changing the number of replicas, using the following command:

```shell
kubectl scale statefulsets "$APP_INSTANCE_NAME-memcached" --namespace "$NAMESPACE" --replicas=[NEW_REPLICAS]
```

where `[NEW_REPLICAS]` is the new number.

# Updating the application

If you want to use an updated image for the Memcached container, use the
following steps:

1. In the Memcached StatefulSet, change the image that is used for the pod
   template:

    ```shell
    kubectl set image statefulset "$APP_INSTANCE_NAME-memcached" \
      memcached=[NEW_IMAGE_URL]
    ```

    where `[NEW_IMAGE_URL]` is the updated image.

1. To check the status of Pods in the StatefulSet, and the progress of
   the new image, run the following command:

    ```shell
    kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME
    ```

1. To verify the image used by the Pods, run the following command:

    ```shell
    kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' | sort
    ```

# Uninstalling the Memcached application

You can delete the Memcached application using the Google Cloud Platform
Console, or using `kubectl`.

1. Navigate to the `memcached` directory.

    ```shell
    cd google-click-to-deploy/k8s/memcached
    ```

1. Expand the manifest template

    Use `envsubst` to expand the template. It is recommended that you save the
    expanded manifest file for future updates to the application.

    ```shell
    awk 'BEGINFILE {print "---"}{print}' manifest/* \
      | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_MEMCACHED $REPLICAS' \
      > "${APP_INSTANCE_NAME}_manifest.yaml"
    ```

1. Run the `delete` command

    ```shell
    kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
    ```

Optionally, if you don't need the deployed application or the GKE cluster,
delete the cluster using this command:

```shell
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```

# Logging and Monitoring

To set up logging for Memcached solution using Stackdriver, follow the steps in https://kubernetes.io/docs/tasks/debug-application-cluster/logging-stackdriver/#verifying-your-logging-agent-deployment.
