# Overview

Apache Airflow is an open-source tool to programmatically author, schedule, and monitor workflows.

For more information, visit the Airflow [official website](https://airflow.apache.org/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

![Architecture diagram](resources/airflow-k8s-app-architecture.png)

This app offers "list of resources".

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! To install this Airflow app to a
Google Kubernetes Engine cluster via Google Cloud Marketplace, follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/airflow).

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
export CLUSTER=airflow-cluster
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

Navigate to the `airflow` directory:

```shell
cd click-to-deploy/k8s/airflow
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=airflow
export NAMESPACE=default
```

For the persistent disk provisioning of the PostgreSQL StatefulSet and NFS Shared Volume, you will need to:

- Set the StorageClass name. Check your available options using the command below:
  * ```kubectl get storageclass```
  * Or check how to create a new StorageClass in [Kubernetes Documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#the-storageclass-resource)

- Set the persistent disks size. The default disks size is "5Gi".

```shell
export DEFAULT_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export PSQL_PERSISTENT_DISK_SIZE="5Gi"
export NFS_PERSISTENT_DISK_SIZE="5Gi"
```

Set up the image tag:

It is advised to use a stable image reference, which you can find on:
- [Apache Airflow - Marketplace Container Registry](https://gcr.io/ccm-ops-test-adhoc/airflow).
- [PostgreSQL - Marketplace Container Registry](https://marketplace.gcr.io/google/postgresql).
- [NFS Server - Google Container Registry](https://marketplace.gcr.io/google/nfs-server1).
For example:

```shell
export AIRFLOW_TRACK=2.2
export POSTGRESQL_TRACK=13.4
export NFS_TRACK=1.3
export METRICS_EXPORTER_TAG=0.5
```

Configure the container images:

```shell
export IMAGE_AIRFLOW=marketplace.gcr.io/google/airflow2
export IMAGE_POSTGRESQL=marketplace.gcr.io/google/postgresql13
export IMAGE_NFS=marketplace.gcr.io/google/nfs-server1
export IMAGE_METRICS_EXPORTER=k8s.gcr.io/prometheus-to-sd:${METRICS_EXPORTER_TAG}
```

By default, each deployment has 1 replica, but you can choose to set the
number of replicas for Airflow webserver, scheduler and triggerer.

```shell
export AIRFLOW_WEBSERVER_REPLICAS=3
export AIRFLOW_SCHEDULER_REPLICAS=3
export AIRFLOW_TRIGGERER_REPLICAS=3
```

Set or generate the UI password:

```shell
export AIRFLOW_ADMIN_EMAIL="admin@store.example"
export AIRFLOW_ADMIN_PASSWORD="admin_password"
```

(Optional) Expose the Service externally and configure Ingress:

By default, the Service is not exposed externally. To enable this option, change the value to true.

```shell
export PUBLIC_SERVICE_AND_INGRESS_ENABLED=false
```

(Optional) Enable Stackdriver Metrics Exporter:

> **NOTE:** Your GCP project must have Stackdriver enabled. If you are using a
> non-GCP cluster, you cannot export metrics to Stackdriver.

By default, the application does not export metrics to Stackdriver. To enable
this option, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=false
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template "${APP_INSTANCE_NAME}" chart/airflow \
    --namespace "${NAMESPACE}" \
    --set airflow.image.repo="$IMAGE_AIRFLOW" \
    --set airflow.image.tag="$AIRFLOW_TRACK" \
    --set postgresql.image.repo="$IMAGE_POSTGRESQL" \
    --set postgresql.image.tag="$POSTGRESQL_TRACK" \
    --set nfs.image.repo="$IMAGE_NFS" \
    --set nfs.image.tag="$NFS_TRACK" \
    --set nfs.persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
    --set nfs.persistence.size="${NFS_PERSISTENT_DISK_SIZE}" \
    --set postgresql.persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
    --set postgresql.persistence.size="${PSQL_PERSISTENT_DISK_SIZE}" \
    --set web.replicas="${AIRFLOW_WEBSERVER_REPLICAS:-1}" \
    --set scheduler.replicas="${AIRFLOW_SCHEDULER_REPLICAS:-1}" \
    --set triggerer.replicas="${AIRFLOW_TRIGGERER_REPLICAS:-1}" \
    --set airflow.admin.email="${AIRFLOW_ADMIN_EMAIL}" \
    --set airflow.admin.password="${AIRFLOW_ADMIN_PASSWORD}" \
    --set enablePublicServiceAndIngress="${PUBLIC_SERVICE_AND_INGRESS_ENABLED}" \
    --set metrics.image="$IMAGE_METRICS_EXPORTER" \
    --set metrics.exporter.enabled="$METRICS_EXPORTER_ENABLED" \
    > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Cloud Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

### Open your Airflow website

To get the external IP of your Magento website, use the following command:

```shell
SERVICE_IP=$(kubectl get ingress "${APP_INSTANCE_NAME}-airflow-web" \
  --namespace "${NAMESPACE}" \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "https://${SERVICE_IP}/"
```
The command shows you the URL of your site. In case you don't have Ingress Controller and didn't set `enablePublicServiceAndIngress`, you can expose Webserver port:

```shell
kubectl expose deploy "${APP_INSTANCE_NAME}-web" \
  --namespace "${NAMESPACE}" \
  --type=LoadBalancer --name=airflow-lb
SERVICE_IP=$(kubectl get svc airflow-lb \
  --namespace "${NAMESPACE}" \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "http://${SERVICE_IP}:8080/"
```

# App metrics

## Prometheus metrics

The app can be configured to expose its metrics through the 
[Airflow Exporter](https://github.com/epoch8/airflow-exporter) 
in the [Prometheus format](https://github.com/prometheus/docs/blob/master/content/docs/instrumenting/exposition_formats.md).

You can access the Airflow metrics at `[AIRFLOW-SERVICE]:8080/admin/metrics`, where `[AIRFLOW-SERVICE]` is the
    [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/) `${APP_INSTANCE_NAME}-airflow-svc`.

### Configuring Prometheus to collect the metrics

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


# Scaling up or down

To change the number of replicas of the `Airflow Webserver`, use the following
command, where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment "${APP_INSTANCE_NAME}-web" --namespace $NAMESPACE --replicas=$REPLICAS
```

To change the number of replicas of the `Airflow Scheduler`, use the following
command, where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment "${APP_INSTANCE_NAME}-scheduler" --namespace $NAMESPACE --replicas=$REPLICAS
```

To change the number of replicas of the `Airflow Triggerer`, use the following
command, where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment "${APP_INSTANCE_NAME}-triggerer" --namespace $NAMESPACE --replicas=$REPLICAS
```


# Backup and restore

To back up the application, you must back up the database. The `dags` folder is stored on the PersistentVolumeClaim.

### Set up your local environment

Set up environment variables to match your Airflow installation:

```shell
export APP_INSTANCE_NAME=airflow
export NAMESPACE=default
```

## Backing up data

To back up the dags, copy the files from `$AIRFLOW_HOME/dags`.
Use the following script to copy the plugins folder to a local `extensions` folder:

```shell
mkdir dags
kubectl --namespace $NAMESPACE cp $(kubectl get pod -l component=nfs-server -o jsonpath={..metadata.name}):/exports/dags dags
```

## Backup your database password

Use this command to see a base64-encoded version of your PostgreSQL password:

```shell
kubectl get secret $APP_INSTANCE_NAME-config-envs --namespace $NAMESPACE -o jsonpath='{.data._AIRFLOW_WWW_USER_PASSWORD}' | base64 -d
```


### Establish the PostgreSQL connection

To back up the Airflow database, you must connect to the PostgreSQL host and port.
Using a separate terminal, create a local proxy using the following `kubectl`
command:

```shell
kubectl port-forward "svc/${APP_INSTANCE_NAME}-postgresql-svc" 5432 --namespace ${NAMESPACE}
```

## Backing up PostgreSQL

To create the backup, you need the `postgresql-client-13` package. To install the
package, on Debian-based distributions, run:

```shell
sudo apt-get install postgresql-client-13
```
To create the backup, run the following command:

```shell
pg_dump -U airflow -h 127.0.0.1 -p 5432 airflow > psql-backup.sql
```

### Restore your configuration

1. Use this command to restore your data from `psql-backup.sql`:

```shell
psql -U airflow -h 127.0.0.1 -p 5432 airflow > psql-backup.sql
```

2. Use the following command to copy the contents of your local `dags` folder to `$AIRFLOW_HOME/dags` folder in the NFS Server Pod:
   
```shell
kubectl --namespace $NAMESPACE cp dags $(kubectl get pod -l component=nfs-server -o jsonpath={..metadata.name}):/exports/dags
```

3. Finally, restart the Airflow pods:

```shell
kubectl rollout restart deploy $APP_INSTANCE_NAME-web --namespace $NAMESPACE
kubectl rollout restart deploy $APP_INSTANCE_NAME-scheduler --namespace $NAMESPACE
kubectl rollout restart deploy $APP_INSTANCE_NAME-triggerer --namespace $NAMESPACE
```

# Uninstall the app

## Using the Google Cloud Console

- In the Cloud Console, open
   [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

- From the list of apps, click **Airflow**.

- On the Application Details page, click **Delete**.

## Using the command-line

### Prepare your environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=airflow
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

### Delete the Persistent Volumes of your installation

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

If you don't need the deployed app or the GKE cluster, delete the cluster
by using this command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```
