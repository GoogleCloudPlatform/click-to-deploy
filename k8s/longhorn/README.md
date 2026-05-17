# Overview

Longhorn is a lightweight, reliable and easy-to-use distributed block storage system for Kubernetes. 

For more information, visit the Longhorn [official website](https://longhorn.io/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! To install this Longhorn app to a
Google Kubernetes Engine cluster via Google Cloud Marketplace, follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/longhorn).

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

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine (GKE) cluster

Create a new cluster from the command-line:

```shell
export CLUSTER=longhorn-cluster
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

Navigate to the `longhorn` directory:

```shell
cd click-to-deploy/k8s/longhorn
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=longhorn
export NAMESPACE=default
```

Set up the image tag:

```shell
export TRACK_MANAGER=v1.3.x-head
export TRACK_LONGHORN=v1.3.2
export TRACK_CSI_ATTACHER=v3.4.0
export TRACK_CSI_PROVISIONER=v2.1.2
export TRACK_CSI_NODE_DRIVER_REGISTRAR=v2.5.0
export TRACK_CSI_RESIZER=v1.2.0
export TRACK_CSI_SNAPSHOTTER=v3.0.3

```

Configure the container images:

```shell
export IMAGE_LONGHORN_ENGINE=docker.io/longhornio/longhorn-engine
export IMAGE_LONGHORN_MANAGER=docker.io/longhornio/longhorn-manager
export IMAGE_LONGHORN_UI=docker.io/longhornio/longhorn-ui
export IMAGE_LONGHORN_INSTANCE_MANAGER=docker.io/longhornio/longhorn-instance-manager
export IMAGE_LONGHORN_SHARE_MANAGER=docker.io/longhornio/longhorn-share-manager
export IMAGE_LONGHORN_BACKING_IMAGE_MANAGER=docker.io/longhornio/backing-image-manager
export IMAGE_LONGHORN_CSI_ATTACHER=docker.io/longhornio/csi-attacher
export IMAGE_LONGHORN_CSI_PROVISIONER=docker.io/longhornio/csi-provisioner
export IMAGE_LONGHORN_CSI_NODE_DRIVER_REGISTRAR=docker.io/longhornio/csi-node-driver-registrar
export IMAGE_LONGHORN_CSI_RESIZER=docker.io/longhornio/csi-resizer
export IMAGE_LONGHORN_CSI_SNAPSHOTTER=docker.io/longhornio/csi-snapshotter
```

By default, each deployment has 1 replica, but you can choose to set the
number of replicas for CSI Attacher, Provisioner, Snapshotter and Resizer.

```shell
export LONGHORN_CSI_ATTACHER_REPLICAS=1
export LONGHORN_CSI_PROVISIONER_REPLICAS=1
export LONGHORN_CSI_SNAPSHOTTER_REPLICAS=1
export LONGHORN_CSI_RESIZER_REPLICAS=1

```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template "${APP_INSTANCE_NAME}" chart/longhorn \
    --namespace "${NAMESPACE}" \
    --set longhorn.engine.image.repo="${IMAGE_LONGHORN_ENGINE}" \
    --set longhorn.engine.image.tag="${TRACK_LONGHORN}" \
    --set longhorn.manager.image.repo="${IMAGE_LONGHORN_MANAGER}" \
    --set longhorn.manager.image.tag="${TRACK_LONGHORN}" \
    --set longhorn.ui.image.repo="${IMAGE_LONGHORN_UI}" \
    --set longhorn.ui.image.tag="${TRACK_LONGHORN}" \
    --set longhorn.instancemanager.image.repo="${IMAGE_LONGHORN_INSTANCE_MANAGER}" \
    --set longhorn.instancemanager.image.tag="${TRACK_MANAGER}" \
    --set longhorn.sharemanager.image.repo="${IMAGE_LONGHORN_SHARE_MANAGER}" \
    --set longhorn.sharemanager.image.tag="${TRACK_MANAGER}" \
    --set longhorn.backingimagemanager.image.repo="${IMAGE_LONGHORN_BACKING_IMAGE_MANAGER}" \
    --set longhorn.backingimagemanager.image.tag="${TRACK_MANAGER}" \
    --set longhorn.csiattacher.image.repo="${IMAGE_LONGHORN_CSI_ATTACHER}" \
    --set longhorn.csiattacher.image.tag="${TRACK_CSI_ATTACHER}" \
    --set longhorn.csiprovisioner.image.repo="${IMAGE_LONGHORN_CSI_PROVISIONER}" \
    --set longhorn.csiprovisioner.image.tag="${TRACK_CSI_PROVISIONER}" \
    --set longhorn.csinodedriverregistrar.image.repo="${IMAGE_LONGHORN_CSI_NODE_DRIVER_REGISTRAR}" \
    --set longhorn.csinodedriverregistrar.image.tag="${TRACK_CSI_NODE_DRIVER_REGISTRAR}" \
    --set longhorn.csiresizer.image.repo="${IMAGE_LONGHORN_CSI_RESIZER}" \
    --set longhorn.csiresizer.image.tag="${TRACK_CSI_RESIZER}" \
    --set longhorn.csisnapshotter.image.repo="${IMAGE_LONGHORN_CSI_SNAPSHOTTER}" \
    --set longhorn.csisnapshotter.image.tag="${TRACK_CSI_SNAPSHOTTER}" \
    --set longhorn.csiattacher.replicas="${LONGHORN_CSI_ATTACHER_REPLICAS:-1}" \
    --set longhorn.csiprovisioner.replicas="${LONGHORN_CSI_PROVISIONER_REPLICAS:-1}" \
    --set longhorn.csisnapshotter.replicas="${LONGHORN_CSI_SNAPSHOTTER_REPLICAS:-1}" \
    --set longhorn.csiresizer.replicas="${LONGHORN_CSI_RESIZER_REPLICAS:-1}" \
    > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f ${APP_INSTANCE_NAME}_manifest.yaml
```

The solution contains several CRDs. In case of `unable to recognize` errors, install them before installing the manifest:

```shell
kubectl apply -f ./chart/longhorn/templates/crds/
kubectl apply -f ${APP_INSTANCE_NAME}_manifest.yaml
```

#### View the app in the Google Cloud Console

To get the Cloud Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

### Access Longhorn through an external IP address

By default, the application does not have an external IP address. 
To create an external IP address, run the following command:

```
kubectl patch svc "$APP_INSTANCE_NAME-longhorn-frontend" \
  --namespace "$NAMESPACE" \
  --patch '{"spec": {"type": "LoadBalancer"}}'
```

> **NOTE:** It might take some time for the external IP to be provisioned.

### Access the Longhorn's UI service

If you run your Longhorn cluster behind a LoadBalancer, 
you can get the external IP of the longhorn-frontend service using the following command:

```shell
UI_IP=$(kubectl get svc ${APP_INSTANCE_NAME-longhorn-frontend} \
  --namespace ${NAMESPACE} \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "http://$UI_IP"
```

# Scaling up or down

To change the number of replicas of the `CSI Attacher`, use the following
command, where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment csi-attacher --namespace $NAMESPACE --replicas=$REPLICAS
```

To change the number of replicas of the `CSI Provisioner`, use the following
command, where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment csi-provisioner --namespace $NAMESPACE --replicas=$REPLICAS
```

To change the number of replicas of the `CSI Snapshotter`, use the following
command, where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment csi-snapshotter --namespace $NAMESPACE --replicas=$REPLICAS
```

To change the number of replicas of the `CSI Resizer`, use the following
command, where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment csi-resizer --namespace $NAMESPACE --replicas=$REPLICAS
```

# Uninstall the app

## Using the Google Cloud Console

- In the Cloud Console, open
   [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

- From the list of apps, click **Longhorn**.

- On the Application Details page, click **Delete**.

## Using the command-line

### Prepare your environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=longhorn
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend that you use a `kubectl` version that is the same
> version as that of your cluster. Using the same versions for `kubectl` and
> the cluster helps to avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

You can also delete the resources by using types and a label:

```shell
kubectl delete application --namespace $NAMESPACE --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

**NOTE:** This will delete only the `longhorn` solution. All `longhorn`-managed resources will remain available.

### Delete the GKE cluster

If you don't need the deployed app or the GKE cluster, delete the cluster
by using this command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```

