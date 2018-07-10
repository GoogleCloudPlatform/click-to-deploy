# Overview
InfluxDB is an open source database for storing time series data. The source of time series data may come from logging and monitoring systems and IoT devices.

This is a single-instance version of InfluxDB. Multi-instance version of InfluxDB requires commercial license.

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

Configure InfluxDB administrator account:

```shell
export INFLUXDB_ADMIN_USER=influxdb_admin
```

Configure password for InfluxDB administrator account (the value has to be encoded in base64)

```shell
export INFLUXDB_ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1 | tr -d '\n' | base64)
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
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_INFLUXDB $INFLUXDB_ADMIN_USER $INFLUXDB_ADMIN_PASSWORD' \
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

TODO by rafalbiegacz@ after merging

# Scaling

This is a single-instance version of InfluxDB. You cannot scale it.

If you are interested in multi-instance/enterprise version of InfluxDB, please, visit [InfluxDB website](https://www.influxdata.com/).

# Backup and Restore

TODO by rafalbiegacz@ after merging

# Upgrade

This is single-instance InfluxDB solution:
- Upgrade will case some downtime of your application
- Configuration and data of InfluxDB will be retained.

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

# Uninstall the Application

## Using GKE UI

Navigate to `GKE > Applications` in GCP console. From the list of applications, click on the one
that you wish to uninstall.

On the new screen, click on the `Delete` button located in the top menu. It will remove
the resources attached to this application.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=influxdb-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** Please keep in mind that `kubectl` guarantees support for Kubernetes server in +/- 1 versions. It means that for instance if you have kubectl in version `1.10.*` and Kubernetes server `1.8.*`, you may experience incompatibility issues, like not removing the *StatefulSets* with apiVersion of *apps/v1beta2*.

If you still have the expanded manifest file used for the installation, you can use it to delete the resources.
Run `kubectl` on expanded manifest file matching your installation:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

Otherwise, delete the resources by indication types and label:

```shell
kubectl delete statefulset,secret,service,serviceaccount,rolebinding,application \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete the persistent volumes of your installation

By design, removal of *StatefulSets* in Kubernetes does not remove the *PersistentVolumeClaims* that
were attached to their Pods. It protects your installations from mistakenly deleting stateful data.

If you wish to remove the *PersistentVolumeClaims* with their attached persistent disks, run the
following `kubectl` commands:

```shell
for i in $(kubectl get pvc --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME \
  --output jsonpath='{.items[*].spec.volumeName}');
do
  kubectl delete pv/$i --namespace $NAMESPACE
done

kubectl delete persistentvolumeclaims \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete GKE cluster

Optionally, if you do not need both the deployed application and GKE cluster used for deployment then you can delete the whole GKE cluster using this command:

```shell
export PROJECT=your-gcp-project # or export PROJECT=$(gcloud config get-value project)
export CLUSTER=marketplace-cluster
export ZONE=us-west1-a # or export ZONE=$(gcloud config get-value compute/zone)
```

```
gcloud --project "$PROJECT" container clusters delete "$CLUSTER" --zone "$ZONE"
```
