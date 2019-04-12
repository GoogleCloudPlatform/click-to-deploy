# Overview

SonarQube

For more information on SSonarQube, see the [SonarQube website](https://www.sonarqube.org/).

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
- [helm](https://helm.sh/docs/using_helm/#installing-helm)

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
TAG=9.6
export IMAGE_SONARQUBE="marketplace.gcr.io/google/sonarqube:${TAG}"
export IMAGE_POSTGRESQL="marketplace.gcr.io/google//sonarqube/postgresql9:${TAG}"
export IMAGE_POSTGRESQL_EXPORTER="marketplace.gcr.io/google/postgresql9/exporter:${TAG}"
export IMAGE_METRICS_EXPORTER="marketplace.gcr.io/google/sonarqube/prometheus-to-sd:${TAG}"
```

The image above is referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images,
until you are ready to upgrade. To get the digest for the image, use the
following script:

```shell
IMAGE_SONARQUBE=$(docker pull $IMAGE_SONARQUBE | awk -F: "/^Digest:/ {print gensub(\":.*$\", \"\", 1, \"$IMAGE_SONARQUBE\")\"@sha256:\"\$3}")
IMAGE_POSTGRESQL=$(docker pull $IMAGE_POSTGRESQL | awk -F: "/^Digest:/ {print gensub(\":.*$\", \"\", 1, \"$IMAGE_POSTGRESQL\")\"@sha256:\"\$3}")
IMAGE_POSTGRESQL_EXPORTER=$(docker pull $IMAGE_POSTGRESQL_EXPORTER | awk -F: "/^Digest:/ {print gensub(\":.*$\", \"\", 1, \"$IMAGE_POSTGRESQL_EXPORTER\")\"@sha256:\"\$3}")
IMAGE_METRICS_EXPORTER=$(docker pull $IMAGE_METRICS_EXPORTER | awk -F: "/^Digest:/ {print gensub(\":.*$\", \"\", 1, \"$IMAGE_METRICS_EXPORTER\")\"@sha256:\"\$3}")
```

Create a certificate for PostgreSQL. If you already have a certificate that you
want to use, copy your certificate and key pair in to the `server.crt` and
`server.key` files.

```shell
# create a certificate for postgresql
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout server.key \
    -out server.crt \
    -subj "/CN=postgresql/O=postgresql"

kubectl --namespace $NAMESPACE create secret generic $APP_INSTANCE_NAME-tls \
        --from-file=./server.crt --from-file=./server.key
```

Generate random password for PosgreSQL:

```shell
export POSTGRESQL_DB_PASSWORD=$(openssl rand 9 | openssl base64 -A | openssl base64)
```

Enable Stackdriver Metrics Exporter:

> **NOTE:** Your GCP project should have Stackdriver enabled. For non-GCP clusters, export of metrics to Stackdriver is not supported yet.

By default the integration is disabled. To enable, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=false
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/wordpress \
  --name="$APP_INSTANCE_NAME" \
  --namespace="$NAMESPACE" \
  --set sonarqube.repository=$IMAGE_SONARQUBE \
  --set postgresql.image=$IMAGE_POSTGRESQL \
  --set postgresql.exporter.image=$IMAGE_POSTGRESQL_EXPORTER \
  --set metrics.image=$METRICS_EXPORTER_ENABLED
  --set postgresql.db.password=$DB_PASSWORD > ${APP_INSTANCE_NAME}_manifest.yaml
```
#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster. This installation will create:

- An Application resource, which collects all the deployment resources into one logical entity
- A ServiceAccount for the SonarQube and PostgreSQL Pod.
- A PersistentVolume and PersistentVolumeClaim for SInarQube and PostgreSQL. Note that the volumes isn't be deleted with application. If you delete the installation and recreate it with the same name, the new installation uses the same PersistentVolumes. As a result, there is no new database initialization, and no new password is set.
- A Secret with the PostgreSQL initial random password
- A Deployment with SonarQube and PostgreSQL.
- A Service, which exposes PostgreSQL and SonarQube to usage in cluster.


```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

# Using the app

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```
Application does not exposed to external world. To get access to app run the following command:
```bash
    kubectl port-forward \
      --namespace $NAMESPACE \
      svc/$APP_INSTANCE_NAME-sonarqube-svc \
      9000:9000
```  
App will available on `localhost`.
```bash
http://localhost:9000
```  
Login to web-page with default credentials:
 
```bash
Login: admin
Password: admin
```
Please change credential after first login.


# Application metrics

## Prometheus metrics

The application is configured to expose its metrics through [SonarQube Prometheus Exporter plugin](https://github.com/dmeiners88/sonarqube-prometheus-exporter)
and [PostgreSQL Prometheus.io exporter plugin](https://github.com/wrouesnel/postgres_exporter)
in the [Prometheus format](https://github.com/prometheus/docs/blob/master/content/docs/instrumenting/exposition_formats.md).

Metrics can be read on a HTTP endpoint available at `[POSTGRESQL_CLUSTER_IP]:9187/metrics`,
 and `[SONARQUBE_CLUSTER_IP]:9000/api/prometheus/metrics` where `[POSTGRESQL_CLUSTER_IP]` is the IP address of the PostgreSQL service on Kubernetes cluster, and `[SONARQUBE_CLUSTER_IP]` is IP address of service on Kubernetes cluster.

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

This installation is single instance of SonarQube.


# Backup and restore
## Backing up PostgreSQL

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
## Backing up SonarQube property 