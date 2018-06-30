# Overview
InfluxDB is an open source database for storing time series data. The source of time series data may come from logging and monitoring systems and IoT devices.

This is a single-instance version of InfluxDB. 

If you are interested in enterprise version of InfluxDB or you would like to learn more about InfluxDB in general, please, visit [InfluxDB website](https://www.influxdata.com/).

## About Google Click to Deploy K8s Solutions

Popular open source software stacks on Kubernetes packaged by Google and made available in Google Cloud Marketplace.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this InfluxDB app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/influxdb).

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
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
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

Navigate to the `influxdb` directory.

```shell
cd google-click-to-deploy/k8s/influxdb
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export APP_INSTANCE_NAME=influxdb-1
export NAMESPACE=default
```

Configure the container images.

```shell
export IMAGE_INFLUXDB="gcr.io/k8s-marketplace-eap/google/influxdb:latest"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
for i in "IMAGE_INFLUXDB"; do
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
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_INFLUXDB' \
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

TBD

# Scaling

This is a single-instance version of InfluxDB. You cannot scale it.

If you are interested in enterprise version of InfluxDB, please, visit [InfluxDB website](https://www.influxdata.com/).

# Backup and Restore

TBD

# Update

This procudure assumes that you have a new image for InfluxDB container published and being available to your Kubernetes cluster. The new image is available at <url-pointing-to-new-image>.

Start with modification of the image used for pod temaplate within InfluxDB StatefulSet:

```shell
kubectl set image statefulset "$APP_INSTANCE_NAME-influxdb" \
  influxdb=<url-pointing-to-new-image>
```

where `<url-pointing-to-new-image>` is the new image.

To check the status of Pods in the StatefulSet and the progress of deployment of new image run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME
```

To check the current image used by pods within `Influxdb` K8s application, you can run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' | sort
```

# Deletion

You can uninstall/delete InfluxDB application either using Google Cloud Console or using K8s Apps tools.

* Navigate to the `influxdb` directory.

```shell
cd google-click-to-deploy/k8s/influxdb
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

To set up logging for InfluxDB solution using Stackdriver, please, follow the instructuction decomented here: https://kubernetes.io/docs/tasks/debug-application-cluster/logging-stackdriver/#verifying-your-logging-agent-deployment
