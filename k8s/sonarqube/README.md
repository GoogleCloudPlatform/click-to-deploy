# Overview

SonarQube is an open source platform to perform automatic reviews with static analysis of code to detect bugs,
code smells and security vulnerabilities on 25+ programming languages including Java, C#, JavaScript, TypeScript,
C/C++, COBOL and more. SonarQube is the only product on the market that supports a leak approach as a practice to code quality.

For more information on SonarQube, see the [SonarQube website](https://www.sonarqube.org/).

## About Google Click to Deploy

Popular open source software stacks on Kubernetes packaged by Google and made available in Google Cloud Marketplace.

## Design

![Architecture diagram](resources/sonarqube-k8s-app-architecture.png)

### SonarQube application contains:

- An Application resource, which collects all the deployment resources into one logical entity
- A ServiceAccount for the SonarQube and PostgreSQL Pod.
- A PersistentVolume and PersistentVolumeClaim for SonarQube and PostgreSQL. Note that the volumes won't be deleted with application. If you delete the installation and recreate it with the same name, the new installation uses the same PersistentVolumes. As a result, there is no new database initialization, and no new password is set.
- A Secret with the PostgreSQL initial random password
- A Deployment with SonarQube and PostgreSQL.
- A Service, which exposes PostgreSQL and SonarQube to usage in cluster

PostgreSQL exposing by service with type ClusterIP, which makes it available for SonarQube only in cluster network.
SonarQube exposing by service with type ClusterIP, which makes it available only in private network, but below described how to connect to SonarQube.
All data and extensions of SonarQube and PostgreSQL stored on PVC which makes the application more stable.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Sample Application to a Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/sonarqube).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local workstation in the
further instructions.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_working_dir=k8s/sonarqube)

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
export CLUSTER=sonarqube-cluster
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

### Install the application

Navigate to the `sonarqube` directory:

```shell
cd click-to-deploy/k8s/sonarqube
```

#### Configure the application with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the application. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=sonarqube-1
export NAMESPACE=default
```


Configure the container image:

```shell
export IMAGE_SONARQUBE="marketplace.gcr.io/google/sonarqube7:7.6"
export IMAGE_POSTGRESQL="marketplace.gcr.io/google/postgresql9:9.6-kubernetes"
export IMAGE_POSTGRESQL_EXPORTER="marketplace.gcr.io/google/postgresql9:exporter"
export IMAGE_METRICS_EXPORTER="k8s.gcr.io/prometheus-to-sd:v0.5.1"
```

The image above is referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images,
until you are ready to upgrade. To get the digest for the image, use the
following script:

```shell
for i in "IMAGE_SONARQUBE" "IMAGE_POSTGRESQL" "IMAGE_POSTGRESQL_EXPORTER" "IMAGE_METRICS_EXPORTER"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```

Create a certificate for PostgreSQL. If you already have a certificate that you
want to use, copy your certificate and key pair in to the `server.crt` and
`server.key` files.

```shell
# create a certificate for postgresql
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/server.key \
    -out /tmp/server.crt \
    -subj "/CN=postgresql/O=postgresql"

kubectl --namespace $NAMESPACE create secret generic $APP_INSTANCE_NAME-tls \
        --from-file=/tmp/server.crt --from-file=/tmp/server.key
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
helm template chart/sonarqube \
  --name="$APP_INSTANCE_NAME" \
  --namespace="$NAMESPACE" \
  --set sonarqube.image=$IMAGE_SONARQUBE \
  --set postgresql.image=$IMAGE_POSTGRESQL \
  --set postgresql.exporter.image=$IMAGE_POSTGRESQL_EXPORTER \
  --set postgresql.db.password=$POSTGRESQL_DB_PASSWORD  \
  --set metrics.image=$METRICS_EXPORTER_ENABLED > ${APP_INSTANCE_NAME}_manifest.yaml
```
#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the GCP Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

# Using the SonarQube Community Edition

By default, the application is not exposed externally. To get access to SonarQube, run the following command:

```bash
kubectl port-forward --namespace $NAMESPACE svc/$APP_INSTANCE_NAME-sonarqube-svc 9000:9000
```

Then, navigate to the [http://localhost:9000/metrics](http://localhost:9000/metrics) endpoint. Use the username `admin` and password `admin` to login.

To get access web-page with default credentials:

```bash
http://localhost:9000
Login: admin
Password: admin
```

# Application metrics

## Prometheus metrics

The application is configured to expose its metrics through
[PostgreSQL Server Exporter](https://github.com/wrouesnel/postgres_exporter) in
the
[Prometheus format](https://github.com/prometheus/docs/blob/master/content/docs/instrumenting/exposition_formats.md).

You can access the metrics at `[POSTGRESQL_CLUSTER_IP]:9187/metrics`, where
`[POSTGRESQL_CLUSTER_IP]` is the IP address of the application on Kubernetes
cluster.

### Configuring Prometheus to collect metrics

Prometheus can be configured to automatically collect the application's metrics.
Follow the steps in
[Configuring Prometheus](https://prometheus.io/docs/introduction/first_steps/#configuring-prometheus).

You configure the metrics in the
[`scrape_configs` section](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config).

## Exporting metrics to Stackdriver

The deployment includes a
[Prometheus to Stackdriver (`prometheus-to-sd`)](https://github.com/GoogleCloudPlatform/k8s-stackdriver/tree/master/prometheus-to-sd)
container. If you enabled the option to export metrics to Stackdriver, the
metrics are automatically exported to Stackdriver and visible in
[Stackdriver Metrics Explorer](https://cloud.google.com/monitoring/charts/metrics-explorer).
The name of each metric starts with the application's name, which you define in
the `APP_INSTANCE_NAME` environment variable.

The exporting option might not be available for GKE on-prem clusters.

> Note: Stackdriver has [quotas](https://cloud.google.com/monitoring/quotas) for
> the number of custom metrics created in a single GCP project. If the quota is
> met, additional metrics might not show up in the Stackdriver Metrics Explorer.

You can remove existing metric descriptors using
[Stackdriver's REST API](https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.metricDescriptors/delete).

# Scaling

SonarQube Community Edition doest not support scaling.

# Backup and restore

[From official documentation](https://docs.sonarqube.org/7.6/architecture/architecture-integration/)
The SonarQube Platform is made of 4 components:

- One SonarQube Server starting 3 main processes:

   - Web Server for developers, managers to browse quality snapshots and configure the SonarQube instance
   - Search Server based on Elasticsearch to back searches from the UI
   - Compute Engine Server in charge of processing code analysis reports and saving them in the SonarQube Database

- One SonarQube Database to store:

   - the configuration of the SonarQube instance (security, plugins settings, etc.)
   - the quality snapshots of projects, views, etc.

- Multiple SonarQube Plugins installed on the server, possibly including language, SCM, integration, authentication, and governance plugins

- One or more SonarScanners running on your Build / Continuous Integration Servers to analyze projects

For our application database the most important place, `plugins` folder stored on PVC (Persistent Volume Claim).

## Backing up plugin and data

This shell script will create copy of plugins folder in current folder
```shell
kubectl --namespace $NAMESPACE cp $(kubectl -n$NAMESPACE get pod -oname | \
                sed -n /\\/$APP_INSTANCE_NAME-sonarqube/s.pods\\?/..p):/opt/sonarqube/extensions/ ./
```

This shell script will create copy of content from folder `data` in current folder:

```shell
kubectl --namespace $NAMESPACE cp $(kubectl -n$NAMESPACE get pod -oname | \
                sed -n /\\/$APP_INSTANCE_NAME-sonarqube/s.pods\\?/..p):/opt/sonarqube/data ./
```

## Backing up PostgreSQL

This shell script will create `postgresql-backup.sql` dump of all DB in PostgreSQL.

```shell
kubectl --namespace $NAMESPACE exec -t \
	$(kubectl -n$NAMESPACE get pod -oname | \
		sed -n /\\/$APP_INSTANCE_NAME-postgresql-deployment/s.pods\\?/..p) \
	-c postgresql-server \
	-- pg_dumpall -c -U postgres > backup.sql
```

## Restoring your PostgreSQL

This shell script will prepare dump for restore

```shell
sed -i '1 i\REVOKE CONNECT ON DATABASE sonar FROM PUBLIC;' backup.sql
sed -i '1 a select pg_terminate_backend(pid) from pg_stat_activity where datname='sonar';' backup.sql
echo "GRANT CONNECT ON DATABASE sonar TO PUBLIC;" >> backup.sql
```

This shell script will restore dump `backup.sql` to PostgreSQL

```shell
cat backup.sql | kubectl --namespace $NAMESPACE exec -i \
	$(kubectl -n$NAMESPACE get pod -oname | \
		sed -n /\\/$APP_INSTANCE_NAME-postgresql-deployment/s.pods\\?/..p) \
	-c postgresql-server \
	-- psql -U postgres
```

This shell script will copy files from current folder to folder `data` in pod
sonarqube

```shell
kubectl --namespace $NAMESPACE cp ./ $(kubectl -n$NAMESPACE get pod -oname | \
         sed -n /\\/$APP_INSTANCE_NAME-sonarqube/s.pods\\?/..p):/opt/sonarqube/data
```

This script will restore extension

```shell
kubectl --namespace $NAMESPACE cp ./ $(kubectl -n$NAMESPACE get pod -oname | \
         sed -n /\\/$APP_INSTANCE_NAME-sonarqube/s.pods\\?/..p):/opt/sonarqube/extensions
```

This shell script will delete old state of SonarQube

```shell
kubectl --namespace $NAMESPACE exec -i \
        $(kubectl -n$NAMESPACE get pod -oname | \
        sed -n /\\/$APP_INSTANCE_NAME-sonarqube/s.pods\\?/..p) \
        -- bash -c "rm -rf /opt/sonarqube/data/es5/* "
```

This shell script will delete SonarQube pod and it will be rescheduled

```shell
kubectl --namespace $NAMESPACE delete pod $(kubectl -n$NAMESPACE get pod -oname | \
        sed -n /\\/$APP_INSTANCE_NAME-sonarqube/s.pods\\?/..p)
```

# Uninstall the Application

## Using the Google Cloud Platform Console

1. In the GCP Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of applications, click **Sonarqube-1**.

1. On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=sonarqube-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend to use a kubectl version that is the same as the version of your cluster. Using the same versions of kubectl and the cluster helps avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

Otherwise, delete the resources using types and a label:

```shell
kubectl delete application,deployment,service,pvc \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete the persistent volumes of your installation

By design, the removal of StatefulSets in Kubernetes does not remove
PersistentVolumeClaims that were attached to their Pods. This prevents your
installations from accidentally deleting stateful data.

To remove the PersistentVolumeClaims with their attached persistent disks, run
the following `kubectl` commands:

```shell
for pv in $(kubectl get pvc --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME \
  --output jsonpath='{.items[*].spec.volumeName}');
do
  kubectl delete pv/$pv --namespace $NAMESPACE
done

kubectl delete persistentvolumeclaims \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete the GKE cluster

Optionally, if you don't need the deployed application or the GKE cluster,
delete the cluster using this command:

```
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```

