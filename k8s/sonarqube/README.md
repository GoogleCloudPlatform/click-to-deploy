# Overview

SonarQube

For more information on SonarQube, see the [SonarQube website](https://www.sonarqube.org/).

## About Google Click to Deploy

Popular open source software stacks on Kubernetes packaged by Google and made available in Google Cloud Marketplace.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Sample Application to a Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/sonarqube).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local workstation in the
further instructions.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_working_dir=k8s/sample-app)

### Prerequisites

#### Set up command line tools

You'll need the following tools in your environment:

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [docker](https://docs.docker.com/install/)
- [openssl](https://www.openssl.org/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a cluster from the command line. If you already have a cluster that
you want to use, this step is optional.

```shell
export CLUSTER=app-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

#### Configure kubectl to connect to the cluster

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo:

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

You need to run this command once for each cluster.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps) community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `sonarqube` directory:

```shell
cd click-to-deploy/k8s/sonarqube
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=sonarqube-1
export NAMESPACE=default
```


Configure the container image:

```shell
export IMAGE_SONARQUBE="marketplace.gcr.io/google/sonarqube7:latest"
export IMAGE_POSTGRESQL="marketplace.gcr.io/google/postgresql9:latest"
```

The image above is referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images,
until you are ready to upgrade. To get the digest for the image, use the
following script:

```shell
for i in "IMAGE_SONARQUBE" "IMAGE_POSTGRESQL"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```
Set or generate passwords:

```shell
# Install pwgen and base64
sudo apt-get install -y pwgen cl-base64

# Set the root and WordPress database passwords
export DB_PASSWORD="$(pwgen 16 1 | tr -d '\n' | base64)"

```



#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/sonarqube \
  --name="$APP_INSTANCE_NAME" \
  --namespace="$NAMESPACE" \
  --set sonarqube.repository=$IMAGE_WORDPRESS \
  --set sonarqube.volumeSize=20
  --set postgresql.image=$IMAGE_POSTGRESQL_ \
  --set postgresql.db.password=$DB_PASSWORD \
  --set postgresql.volumeSize=20 > ${APP_INSTANCE_NAME}_manifest.yaml
```
#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster.

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```


#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

#### Reach the webpage

```shell
kubectl get svc ${APP_INSTANCE_NAME}
```

Result of command will shows you external IP address and port. 

#Using the app 


## How to use SonarQube 
How to use SonarQube you can find in [official documentation](https://docs.sonarqube.org/latest/setup/get-started-2-minutes/)  

# Scaling

This installation is single instance of SonarQube.

# Backup and restore
All configuration of Sonarqube stored in database so main point is to backup database.
## Backing up PostgreSQL of SonqrQube app

```shell
kubectl --namespace $NAMESPACE exec -t \
	$(kubectl -n$NAMESPACE get pod -oname | \
		sed -n /\\/$APP_INSTANCE_NAME-postgresql-deployment/s.pods\\?/..p) \
	-- pg_dumpall -c -U postgres > postgresql-backup.sql
```

## Restoring your data

```shell
cat postgresql-backup.sql | kubectl --namespace $NAMESPACE exec -i \
	$(kubectl -n$NAMESPACE get pod -oname | \
		sed -n /\\/$APP_INSTANCE_NAME-postgresql-deployment/s.pods\\?/..p) \
	-- psql -U postgres
```


# Logging and Monitoring
By default logs exports to Stackdrive, more information in [official documentation](https://cloud.google.com/stackdriver/)
also (optional) all metrics could be exported via Prometheus.
