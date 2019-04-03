# Overview

Memcached is an open source in-memory key-value store. The key features of this solution include high performance and ease of distribution.
Although Memcached is intended to be use with dynamic web applications, it can be used as a caching system for a number of databases.

To learn more about Memcached, visit the [Memcached website](https://memcached.org/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

## Design

![Architecture diagram](resources/memcached-k8s-app-architecture.png)

### Solution Information

StatefulSet Kubernetes object is used to manage all Memcached pods within this K8s application. Each pod runs a single instance of Memcached process which listens on 11211 TCP port.

All pods are behind Service object. Memcached service is not exposed to the external traffic as this Memcached K8s application is meant to be an internal cache of a system
and memory of Memcached instances is not encrypted in any way and communication to Memcached instances happens over plain text.
Memcached Service also doesn’t have a service IP address to allow for discovery of IP addresses of all Memcached pods.
Usually, Memcached clients discover IP addresses of Memcached instances on their own and implement a mechanism to query and to distribute their requests to the pool of Memcached instances.

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Memcached app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/memcached).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local workstation in the
further instructions.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_working_dir=k8s/memcached)

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [pip](https://pip.pypa.io/en/stable/installing/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

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

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `memcached` directory:

```shell
cd click-to-deploy/k8s/memcached
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

Enable Stackdriver Metrics Exporter:

 > **NOTE:** Your GCP project should have Stackdriver enabled. For non-GCP clusters, export of metrics to Stackdriver is not supported yet.

By default the integration is disabled. To enable, change the value to `true`.

 ```shell
export METRICS_EXPORTER_ENABLED=false
```

Configure the container image:

```shell
TAG=1.5
export IMAGE_MEMCACHED="marketplace.gcr.io/google/memcached:${TAG}"
export IMAGE_METRICS_EXPORTER="marketplace.gcr.io/google/memcached/prometheus-to-sd:${TAG}"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images,
until you are ready to upgrade. To get the digest for the image, use the
following script:

```shell
for i in "IMAGE_METRICS_EXPORTER" "IMAGE_MEMCACHED"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "$NAMESPACE"
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/memcached \
  --name $APP_INSTANCE_NAME \
  --namespace $NAMESPACE \
  --set memcached.replicas=$REPLICAS \
  --set memcached.image=$IMAGE_MEMCACHED \
  --set metrics.image=$IMAGE_METRICS_EXPORTER \
  --set metrics.enabled=$METRICS_EXPORTER_ENABLED > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

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

1. Configure your application to use the Memcached cluster as a cache.
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
kubectl get pods -o wide -l app.kubernetes.io/name=$APP_INSTANCE_NAME --namespace "$NAMESPACE"
```

To get the IP addresses of your Memcached instances from within the very Kubernetes cluster
(e.g. from a Memcached Pod) run the following command:

```shell
nslookup $APP_INSTANCE_NAME-memcached-svc.$NAMESPACE.svc.cluster.local
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

# Application metrics

## Prometheus metrics

The application is configured to expose its metrics through
[Memcached Exporter](https://github.com/prometheus/memcached_exporter)
in the [Prometheus format](https://github.com/prometheus/docs/blob/master/content/docs/instrumenting/exposition_formats.md).
For more detailed information about the plugin setup, see the [Memcached Exporter documentation](https://github.com/prometheus/memcached_exporter/blob/master/README.md).
Metrics can be read on a single HTTP endpoint available at `[POD_IP]:9150/metrics`,
where `[POD_IP]` is the IP read from Kubernetes headless service `$APP_INSTANCE_NAME-memcached-prometheus-svc`.

## Configuring Prometheus to collect the metrics

Prometheus can be configured to automatically collect the application's metrics.
Follow the [Configuring Prometheus documentation](https://prometheus.io/docs/introduction/first_steps/#configuring-prometheus)
to enable metrics scrapping in your Prometheus server. The detailed specification
of `<scrape_config>` used to enable the metrics collection can be found
[here](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config).

## Exporting metrics to Stackdriver

If the option to export application metrics to Stackdriver is enabled,
the deployment includes a [`prometheus-to-sd`](https://github.com/GoogleCloudPlatform/k8s-stackdriver/tree/master/prometheus-to-sd)
(Prometheus to Stackdriver exporter) container.
Then the metrics will be automatically exported to Stackdriver and visible in
[Stackdriver Metrics Explorer](https://cloud.google.com/monitoring/charts/metrics-explorer).

Each metric of the application will have a name starting with the application's name
(matching the variable `APP_INSTANCE_NAME` described above).

The exporting option might not be available for GKE on-prem clusters.

> Note: Please be aware that Stackdriver has [quotas](https://cloud.google.com/monitoring/quotas)
for the number of custom metrics created in a single GCP project. If the quota is met,
additional metrics will not be accepted by Stackdriver, which might cause that some metrics
from your application might not show up in the Stackdriver's Metrics Explorer.

Existing metric descriptors can be removed through
[Stackdriver's REST API](https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.metricDescriptors/delete).

# Scaling

You can scale your Memcached service up or down by changing the number of replicas, using the following command:

```shell
kubectl scale statefulsets "$APP_INSTANCE_NAME-memcached" \
  --namespace "$NAMESPACE" \
  --replicas=[NEW_REPLICAS]
```

where `[NEW_REPLICAS]` is the new number.

# Updating the application

If you want to use an updated image for the Memcached container, use the
following steps:

1. In the Memcached StatefulSet, change the image that is used for the pod
   template:

    ```shell
    kubectl set image statefulset "$APP_INSTANCE_NAME-memcached" \
      --namespace "$NAMESPACE" memcached=[NEW_IMAGE_REFERENCE]
    ```

    where `[NEW_IMAGE_REFERENCE]` is the updated image.

1. To check the status of Pods in the StatefulSet, and the progress of
   the new image, run the following command:

    ```shell
    kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME --namespace "$NAMESPACE"
    ```

1. To verify the image used by the Pods, run the following command:

    ```shell
    kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME --namespace "$NAMESPACE" -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' | sort
    ```

# Uninstalling the Memcached application

You can delete the Memcached application using the Google Cloud Platform
Console, or using `kubectl`.

1. Navigate to the `memcached` directory.

    ```shell
    cd click-to-deploy/k8s/memcached
    ```

1. Expand the manifest template

    Use `helm template` to expand the template. We recommend that you save the
    expanded manifest file for future updates to the application.

    ```shell     
    helm template chart/memcached \
     --name $APP_INSTANCE_NAME \
     --namespace $NAMESPACE \
     --set memcached.replicas=$REPLICAS \
     --set memcached.image=$IMAGE_MEMCACHED > "${APP_INSTANCE_NAME}_manifest.yaml"
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
