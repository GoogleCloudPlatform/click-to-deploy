# Overview

The leading open source automation server, Jenkins provides hundreds of plugins to support building, deploying and automating any project.

Please, visit [Jenkins website](https://jenkins.io/) to know more about it.

## About Google Click to Deploy

Popular open source software stacks on Kubernetes packaged by Google and made available in Google Cloud Marketplace.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Jenkins app to a Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/jenkins).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [docker](https://docs.docker.com/install/)

#### Configuration referenced in this readme

```shell
export CLUSTER=marketplace-cluster
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
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

Do a one-time setup for your cluster to understand Application resource via installing Application's Custom Resource Definition.

<!--
To do that, navigate to `k8s/vendor` subdirectory of the repository and run the following command:
-->

```shell
kubectl apply -f click-to-deploy/k8s/vendor/marketplace-tools/crd/*
```

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `jenkins` directory.

```shell
cd click-to-deploy/k8s/jenkins
```

#### Configure the app with environment variables

Choose application instance name, namespace and Jenkins image for the app.

```shell
export APP_INSTANCE_NAME=jenkins-1
export NAMESPACE=default

export IMAGE_JENKINS="marketplace.gcr.io/google/jenkins:latest"
```

Create namespace if it doesn't exist.

```shell
kubectl create namespace $NAMESPACE
```

Create certificate. If you already have a certificate, you can omit creation,
just put your certificate and key pair in /tmp/tls.crt and /tmp/tls.key files.

```shell
# create a certificate for jenkins
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/tls.key \
    -out /tmp/tls.crt \
    -subj "/CN=jenkins/O=jenkins"

# create a secret for K8s ingress SSL
kubectl --namespace $NAMESPACE create secret generic $APP_INSTANCE_NAME-tls \
        --from-file=/tmp/tls.crt --from-file=/tmp/tls.key
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
docker pull $IMAGE_JENKINS | awk -F: "/^Digest:/ {print gensub(\":.*$\", \"\", 1, \"$IMAGE_JENKINS\")\"@sha256:\"\$3}"
```

#### Expand the manifest template

Use `envsubst` to expand the template. It is recommended that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_JENKINS' \
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

Get the Jenkins HTTP/HTTPS address and Jenkins master pod name and go to login page.

```shell
EXTERNAL_IP=$(kubectl -n$NAMESPACE get ingress -l "app.kubernetes.io/name=$APP_INSTANCE_NAME" \
  -ojsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
MASTER_POD=$(kubectl -n$NAMESPACE get pod -oname | sed -n /\\/$APP_INSTANCE_NAME-jenkins-deployment/s.pods\\?/..p)

echo https://$EXTERNAL_IP/
```

For HTTPS you may have to accept a certificate (we created a temporary one). Now you probably need a password.

```shell
kubectl -n$NAMESPACE exec $MASTER_POD cat /var/jenkins_home/secrets/initialAdminPassword
```

#### Follow on screen instructions

- install plugins
- create first admin user
- set jenkins URL (default is ok and you can change it later)
- start using your fresh Jenkins installation

# Scaling

This installation is single master. If you need more power, just configure additional jenkins workers (slaves).

# Backup

Copy content of jenkins persistent volume or install Jenkins backup plugin (Backup plugin -- Backup or restore your Hudson/Jenkins files) here:

```shell
echo https://$EXTERNAL_IP/pluginManager/available
```

set "Backup directory" to "/var/jenkins_home", configure it to use .tar.gz format and set other backup options here:

```shell
echo https://$EXTERNAL_IP/backup/backupsettings
```

create backup from Jenkins UI here:

```shell
echo https://$EXTERNAL_IP/backup/launchBackup
```

copy your newly created backup file to your workstation:

```shell
kubectl -n$NAMESPACE cp $MASTER_POD:/var/jenkins_home/<YOUR-BACKUP-FILE-NAME.tar.gz> /tmp
```
# and Restore

Copy backup into jenkins persistent volume or copy backup file to Jankins container:

```shell
kubectl -n$NAMESPACE cp /tmp/<YOUR-BACKUP-FILE-NAME.tar.gz> $MASTER_POD:/var/jenkins_home/
```

and use Jenkins backup plugin to restore configuration here:

```shell
echo https://$EXTERNAL_IP/backup/launchrestore
```

# Update and Upgrade

Just kill your Jenkins pod and let Kubernetes install new version (please, consider creating backup before).

```shell
### did I mention backup?
kubectl -n$NAMESPACE delete pod $MASTER_POD
```

# Deletion

Warning! Nothing will be left, persistent volume will be deleted as well and there is no "are you sure?" question. Have you thought about backup?

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

# Logging and Monitoring

This Jenkins installation logs to [Stackdriver](https://cloud.google.com/monitoring/)

