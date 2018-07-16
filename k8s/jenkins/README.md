# Overview

The leading open source automation server, Jenkins provides hundreds of plugins to support building, deploying and automating any project.

Please, visit [Jenkins website](https://jenkins.io/) to know more about it.

## About Google Click to Deploy

Popular open source software stacks on Kubernetes packaged by Google and made available in Google Cloud Marketplace.

# Installation

## Quick install with Google Cloud Marketplace

Install this Jenkins app to a Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/jenkins2).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

If you don't have gcloud command authenticated (or installed), please, follow this procedure to configure it for the first time.
- [Download and authenticate gcloud](https://cloud.google.com/sdk/#Quick_Start)

#### Configuration referenced in this readme

```shell
### a bit of configuration
### feel free to put it in a file for future use
export CLUSTER=a-cluster
export ZONE=us-west1-a
```

#### Create a Google Kubernetes Engine cluster

This step is optional if you have a cluster running and don't need a new one.

```shell
gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

#### Configure kubectl to use specific cluster

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

Navigate to the `jenkins` directory.

```shell
cd google-click-to-deploy/k8s/jenkins
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export APP_INSTANCE_NAME=jenkins-1
export NAMESPACE=default
```

Configure the container images.

```shell
export IMAGE_JENKINS="gcr.io/k8s-marketplace-eap/google/jenkins:latest"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
repo=`echo $IMAGE_JENKINS | cut -d: -f1`;
digest=`docker pull $IMAGE_JENKINS | sed -n -e 's/Digest: //p'`;
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

#### Login into your brand new Jenkins instance

Get the Jenkins HTTP/HTTPS address

```shell
echo https://$(kubectl -n$namespace get ingress \
  -ojsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")/
### it's just a funcy way to do this
kubectl -n $namespace get ingress
### and copy ip address into browser
```

For HTTPS you have to accept a certificate (we created a temporary one). Now you probably need a password

```shell
kubectl -n$namespace exec $(kubectl -n$namespace get pod -oname|sed s.pods\\?/..) \
  cat /var/jenkins_home/secrets/initialAdminPassword
```

#### Follow on screen instructions

- install plugins
- create first admin user
- set jenkins URL (default is ok and you can change it later)
- start using your fresh Jenkins installation

# Scaling

This installation is single master. If you need more power, just configure additional jenkins workers (slaves).

# Backup and Restore

Copy content of jenkins persistent volume or install Jenkins backup plugin, configure it to use .tar.gz format and create backup from Jenkins UI.

Copy backup into jenkins persistent volume or use Jenkins backup plugin to restore configuration.

# Update and Upgrade

Just kill your Jenkins pod and let Kubernetes install new version (please, consider creating backup before).

```shell
### did I mention backup?
kubectl -n$namespace delete $(kubectl -n$namespace get pod -oname)
```

# Deletion

Warning! Nothing will left, persistent volume will be deleted as well and there is no "are you sure?" question. Have you thought about backup?

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

# Logging and Monitoring

This Jenkins installation logs to [Stackdriver](https://cloud.google.com/monitoring/)

