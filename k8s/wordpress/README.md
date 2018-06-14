# Overview

WordPress is web software used to create websites and blogs.

[Learn more](https://wordpress.org/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this WordPress app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/wordpress).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

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

Do a one-time setup for your cluster to understand Application resources.

```shell
kubectl apply -f google-marketplace-k8s-app-tools/crd/*
```

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `wordpress` directory.

```shell
cd google-click-to-deploy/k8s/wordpress
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export NAME=wordpress-1
export NAMESPACE=default
```

#### Use `make app/install` to install your application

make will build a deployer container image and then run your installation:

```shell
make app/install
```

#### View the app in the Google Cloud Console

Point your browser to:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${NAME}"
```

### Expose WordPress service

By default, the application does not have an external IP. Run the
following command to expose an external IP:

```
kubectl patch svc "$NAME-wordpress-svc" \
  --namespace "$NAMESPACE" \
  --patch '{"spec": {"type": "LoadBalancer"}}'
```

### Access WordPress site

Get the external IP of the Wordpress site service and visit
the URL printed below in your browser.

```
SERVICE_IP=$(kubectl get \
  --namespace ${NAMESPACE} \
  svc ${NAME}-wordpress-svc \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "http://${SERVICE_IP}"
```

Note that it might take some time for the external IP to be provisioned.

### Set up WordPress

After accessing the WordPress main page, you will see the installation wizard.
Follow the instructions presented on the screen to finish the process.

# Upgrade the Application

## Prepare the environment

We recommend to create backup of your data before starting the upgrade procedure
(TODO - create and link Backup and restore chapter).

Please keep in mind that during the upgrade procedure your WordPress site will be unavailable.

Set your environment variables to match the installation properties:

```shell
NAME=wordpress-1
NAMESPACE=default
```

## Upgrade Wordpress

Set the new image version in an environment variable:

```shell
export IMAGE_WORDPRESS=launcher.gcr.io/google/wordpress4-php5-apache:4.9
```

Update the StatefulSet definition with new image reference:

```shell
kubectl patch statefulset $NAME-wordpress \
  --namespace $NAMESPACE \
  --type='json' \
  --patch="[{ \
      \"op\": \"replace\", \
      \"path\": \"/spec/template/spec/containers/0/image\", \
      \"value\":\"${IMAGE_WORDPRESS}\" \
    }]"
```

Monitor the process with:

```shell
kubectl get pods "$NAME-wordpress-0" \
  --output go-template='Status={{.status.phase}} Image={{(index .spec.containers 0).image}}' \
  --watch
```

The pod should terminated and recreated with new image for `wordpress` container. The final state of
the pod should be `Running` and marked as 1/1 in `READY` column.

## Upgrade MySQL

Set the new image version in an environment variable:

```shell
export IMAGE_MYSQL=launcher.gcr.io/google/mysql5:5.7
```

Update the StatefulSet definition with new image reference:

```shell
kubectl patch statefulset $NAME-mysql \
  --namespace $NAMESPACE \
  --type='json' \
  --patch="[{ \
      \"op\": \"replace\", \
      \"path\": \"/spec/template/spec/containers/0/image\", \
      \"value\":\"${IMAGE_MYSQL}\" \
    }]"
```

Monitor the process with:

```shell
kubectl get pods $NAME-mysql-0 --namespace $NAMESPACE --watch
```

The pod should terminated and recreated with new image for `mysql` container. The final state of
the pod should be `Running` and marked as 1/1 in `READY` column.

To check the current image used for `mysql` container, you can run the following command:

```shell
kubectl get pod $NAME-mysql-0 \
  --namespace $NAMESPACE \
  --output jsonpath='{.spec.containers[0].image}'
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
export APP_INSTANCE_NAME=wordpress-1
export NAMESPACE=default
```

### Prepare the manifest file

If you still have the expanded manifest file used for the installation, you can skip this part.
Otherwise, generate it again. You can use a simplified variables substitution:

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE' \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

### Delete the resources using `kubectl delete`

NOTE: Please keep in mind that `kubectl` guarantees support for Kubernetes server in +/- 1 versions.
  It means that for instance if you have `kubectl` in version 1.10.* and Kubernetes server 1.8.*,
  you may experience incompatibility issues, like not removing the StatefulSets with
  apiVersion of apps/v1beta2.

Run `kubectl` on expanded manifest file matching your installation:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

### Delete the persistent volumes of your installation

By design, removal of StatefulSets in Kubernetes does not remove the PersistentVolumeClaims that
were attached to their Pods. It protects your installations from mistakenly deleting stateful data.

If you wish to remove the PersistentVolumeClaims with their attached persistent disks, run the
following `kubectl` command:

```shell
# specify the variables values matching your installation:
export APP_INSTANCE_NAME=wordpress-1
export NAMESPACE=default

kubectl delete persistentvolumeclaims \
  --namespace $NAMESPACE
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
