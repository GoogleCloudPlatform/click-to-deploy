# Overview

Apache Superset is an open-source software application for data exploration and data visualization. It's enterprise-ready business web application. Superset is able to handle data at petabyte scale and can connect to any SQL based datasource through SQLAlchemy, including modern cloud native databases.

For more information on Superset, see the [Superset Project official documentation](https://superset.apache.org/docs/intro).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

> **NOTE:** The following diagram shows the architecture with the app
> (optionally) exposed externally, using an Ingress and TLS configuration. The
> steps to enable the Ingress resource are in the sections below.

![Architecture diagram](resources/superset-k8s-app-architecture.png)

By default, Ingress is disabled and Superset is exposed using a ClusterIP Service on port `8088`.
You can enable the option to expose the service externally. In that case, Superset's interface is exposed through the ports `8088` using an Ingress resource. The TLS certificates are stored in the `[APP_INSTANCE_NAME]-tls` Secret resource.

Separate StatefulSet Kubernetes objects are used to manage the Superset, PostgreSQL, and Redis instances.

### Superset Workloads

The Superset single-replica StatefulSet runs the [Superset webserver](https://superset.apache.org/) on a [superset-docker](https://github.com/GoogleCloudPlatform/superset-docker) container installation. The credentials for the administrator account are automatically generated, and configured in the app through a Kubernetes Secret.

A Persistent Volume Claim is used for storing persistent configuration data and static assets.

### Redis Workloads

The Redis single-replica StatefulSet runs a [Redis Server](https://redis.io) app on a [redis-docker](https://github.com/GoogleCloudPlatform/redis-docker) container installation. The credentials for the `root` account are automatically generated, and configured in the app through the Secret resource `[APP_INSTANCE_NAME]-redis-secret`.

By default, the Services exposing the Superset app are of type ClusterIP, which means it is accessible only in a private cluster network on port `6379`.

A Persistent Volume Claim is used for storing transient data, such as user-session and caching data.

The [save behaviour](https://redis.io/topics/persistence#snapshotting) may be configured by using the `[APP_INSTANCE_NAME]-redis-config` ConfigMap resource.

This workload also offers an embedded [Redis Prometheus Metrics Exporter](https://github.com/GoogleCloudPlatform/redis-docker/tree/master/exporter).


### PostgreSQL Workloads

The PostgreSQL single-replica StatefulSet runs a [PostgreSQL Server](https://www.postgresql.org/) app on a [postgresql-docker](https://github.com/GoogleCloudPlatform/postgresql-docker) container installation. The credentials for the `superset` account are automatically generated, and configured in the app through the Secret resource `[APP_INSTANCE_NAME]-superset-secret`.

By default, the Services exposing PostgreSQL are of type ClusterIP, which means it is accessible only in a private network on port `5432`.

A Persistent Volume Claim is used for storing all the e-commerce data.

This workfload also offers an embedded [PostgreSQL Prometheus Metrics Exporter](https://github.com/GoogleCloudPlatform/postgresql-docker/tree/master/exporter).


# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Superset app to a Google Kubernetes Engine cluster in Google Cloud Marketplace by following these [on-screen instructions](https://console.cloud.google.com/marketplace/details/google/superset).

## Command line instructions

### Prerequisites

#### Set up command line tools

You'll need the following tools in your development environment. If you're using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your environment by default.

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=superset-cluster
export ZONE=us-west1-a

gcloud container clusters create "${CLUSTER}" --zone "${ZONE}"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}"
```

#### Clone this repo

Clone this repo, as well as the associated tools repo:

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

You need to run this command once.

The Application resource is defined by the [Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps) community. The source code can be found on [github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the app

Navigate to the `superset` directory:

```shell
cd click-to-deploy/k8s/superset
```

#### Configure the app with environment variables

Choose an instance name and [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=superset-1
export NAMESPACE=default
```

For the persistent disk provisioning of the Superset StatefulSets, you will need to:

 * Set the StorageClass name. Check your available options using the command below:
   * ```kubectl get storageclass```
   * Or check how to create a new StorageClass in [Kubernetes Documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#the-storageclass-resource)

 * Set the persistent disk's size. The default disk size for Superset is "10Gi".

```shell
export DEFAULT_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export SUPERSET_PERSISTENT_DISK_SIZE="10Gi"
export DB_PERSISTENT_DISK_SIZE="10Gi"
```


(Optional) Expose the Service externally and configure Ingress:

By default, the Service is not exposed externally. To enable this option, change the value to true.

```shell
export PUBLIC_SERVICE_AND_INGRESS_ENABLED=false
```

(Optional) Enable Stackdriver Metrics Exporter:

> **NOTE:** Your GCP project must have Stackdriver enabled. If you are using a
> non-GCP cluster, you cannot export metrics to Stackdriver.

By default, the app does not export metrics to Stackdriver. To enable this option, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=false
```

Set up the image tag:

It is advised to use stable image reference which you can find on
[Marketplace Container Registry](https://marketplace.gcr.io/google/Superset).
Example:

```shell
export TAG="<BUILD_ID>"
```

Alternatively you can use short tag which points to the latest image for selected version.
> Warning: this tag is not stable and referenced image might change over time.

```shell
export TAG="2.0"
```

Configure the container images:

```shell
export IMAGE_REGISTRY="marketplace.gcr.io/google"

export IMAGE_SUPERSET="${IMAGE_REGISTRY}/superset"
export IMAGE_POSTGRESQL="${IMAGE_REGISTRY}/superset/postgresql:${TAG}"
export IMAGE_REDIS="${IMAGE_REGISTRY}/superset/redis:${TAG}"

export IMAGE_POSTGRESQL_EXPORTER="${IMAGE_REGISTRY}/superset/postgresql-exporter:${TAG}"
export IMAGE_REDIS_EXPORTER="${IMAGE_REGISTRY}/superset/redis-exporter:${TAG}"
export IMAGE_METRICS_EXPORTER="${IMAGE_REGISTRY}/superset/prometheus-to-sd:${TAG}"

export IMAGE_STATSD="${IMAGE_REGISTRY}/superset/statsd-exporter:${TAG}"
```

Set or generate the passwords:

```shell
# Set password. Use your own passwords
export SUPERSET_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1 | tr -d '\n' | base64)"

# Set PostgreSQL superset user password
export POSTGRESQL_DB_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1 | tr -d '\n' | base64)"

# Set redis-server password
export REDIS_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1 | tr -d '\n' | base64)"
```

#### Create TLS certificate for Superset

> Note: You can skip this step if you have disabled external access.

1.  If you already have a certificate that you want to use, copy your certificate and key pair to the `/tmp/tls.crt` and `/tmp/tls.key` files, respectively, then skip to the next step.

    To create a new certificate, run the following command:

    ```shell
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /tmp/tls.key \
        -out /tmp/tls.crt \
        -subj "/CN=Superset/O=Superset"
    ```

2.  Set `TLS_CERTIFICATE_KEY` and `TLS_CERTIFICATE_CRT` variables:

    ```shell
    export TLS_CERTIFICATE_KEY="$(cat /tmp/tls.key | base64)"
    export TLS_CERTIFICATE_CRT="$(cat /tmp/tls.crt | base64)"
    ```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template "${APP_INSTANCE_NAME}" chart/superset \
  --namespace "${NAMESPACE}" \
  --set superset.image.repo="${IMAGE_SUPERSET}" \
  --set statsd.exporter.image="${IMAGE_STATSD}" \
  --set postgresql.serviceAccount="$POSTGRESQL_SERVICE_ACCOUNT" \
  --set superset.image.tag="${TAG}" \
  --set superset.password="${SUPERSET_PASSWORD}" \
  --set superset.persistence.size="${SUPERSET_PERSISTENT_DISK_SIZE}" \
  --set enablePublicServiceAndIngress="${PUBLIC_SERVICE_AND_INGRESS_ENABLED}" \
  --set postgresql.image="$IMAGE_POSTGRESQL" \
  --set postgresql.exporter.image="$IMAGE_POSTGRESQL_EXPORTER" \
  --set postgresql.db.password="$POSTGRESQL_DB_PASSWORD" \
  --set postgresql.persistence.size="$DB_PERSISTENT_DISK_SIZE" \
  --set redis.image="${IMAGE_REDIS}" \
  --set redis.password="${REDIS_PASSWORD}" \
  --set redis.exporter.image="${IMAGE_REDIS_EXPORTER}" \
  --set tls.base64EncodedPrivateKey="${TLS_CERTIFICATE_KEY}" \
  --set tls.base64EncodedCertificate="${TLS_CERTIFICATE_CRT}" \
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

### Open your Superset website

To get the external IP of your Superset webserver, use the following command:

```shell
SERVICE_IP=$(kubectl get ingress "${APP_INSTANCE_NAME}-superset-ingress" \
  --namespace "${NAMESPACE}" \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "https://${SERVICE_IP}/"
```

The command shows you the URL of your site.


# App metrics

## Prometheus metrics

The app can be configured to expose its metrics through the [PostreSQL Server Exporter](https://github.com/GoogleCloudPlatform/postgresql-docker/tree/master/exporter)and [Redis Exporter](https://github.com/GoogleCloudPlatform/redis-docker/tree/master/exporter), in the [Prometheus format](https://github.com/prometheus/docs/blob/master/content/docs/instrumenting/exposition_formats.md).

1.  You can access the Redis metrics at `[REDIS-SERVICE]:9121/metrics`, where `[REDIS-SERVICE]` is the
    [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/) `${APP_INSTANCE_NAME}-redis-svc`.

2.  You can access the PostreSQL metrics at `[POSTGRESQL-SERVICE]:9187/metrics`, where `[POSTGRESQL-SERVICE]` is the
    [Kubernetes Service](https://kubernetes.io/docs/concepts/services-networking/service/) `${APP_INSTANCE_NAME}-postgresql-svc`.

### Configuring Prometheus to collect the metrics

Prometheus can be configured to automatically collect the app's metrics. Follow the steps in [Configuring Prometheus](https://prometheus.io/docs/introduction/first_steps/#configuring-prometheus).

You configure the metrics in the [`scrape_configs` section](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config).

## Exporting metrics to Stackdriver

The deployment includes a [Prometheus to Stackdriver (`prometheus-to-sd`)](https://github.com/GoogleCloudPlatform/k8s-stackdriver/tree/master/prometheus-to-sd) container. If you enabled the option to export metrics to Stackdriver, the metrics are exported to Stackdriver automatically, and visible in [Stackdriver Metrics Explorer](https://cloud.google.com/monitoring/charts/metrics-explorer).

The name of each metric starts with the component's name (`redis` for Redis Server, `mysql` for MariaDB, and `nginx-Superset` for Superset).
Metrics are labeled with `app.kubernetes.io/name`, which includes the app's name as defined in the `APP_INSTANCE_NAME` environment variable.

The export option may not be available for GKE on-prem clusters.

> Note: Stackdriver has [quotas](https://cloud.google.com/monitoring/quotas) for
> the number of custom metrics created in a single GCP project. If the quota is
> met, additional metrics might not show up in the Stackdriver Metrics Explorer.

To remove existing metric descriptors, use [Stackdriver's REST API](https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.metricDescriptors/delete).

# Scaling

This is a single-instance version of Superset. It is not intended to be scaled up in its current configuration.

# Backup and restore

The following steps are based on scripts embedded in the [superset-docker](https://www.github.com/GoogleCloudPlatform/superset-docker) container, which enables you to easily use the Superset CLI commands described in the [Superset documentation](https://devdocs.Superset.com/guides/v2.3/install-gde/install/cli/install-cli-backup.html).

## Backing up PostgreSQL

Your Superset configuration and project data is stored in the PostgreSQL database.
The following script creates a `postgresql/backup.sql` file with the contents of the database.

```shell
mkdir postgresql
kubectl --namespace $NAMESPACE exec -t \
    $(kubectl -n$NAMESPACE get pod -oname | \
        sed -n /\\/$APP_INSTANCE_NAME-postgresql/s.pods\\?/..p) \
    -c postgresql-server \
    -- pg_dumpall -c -U postgres > postgresql/backup.sql
```

## Backup your database password

Use this command to see a base64-encoded version of your PostgreSQL password:

```shell
kubectl get secret $APP_INSTANCE_NAME-secret --namespace $NAMESPACE -o yaml | grep password:
```

### Restore the database

1. Use this command to restore your data from `postgresql/backup.sql`:

    ```shell
    cat postgresql/backup.sql | kubectl --namespace $NAMESPACE exec -i \
      $(kubectl -n$NAMESPACE get pod -oname | \
        sed -n /\\/$APP_INSTANCE_NAME-postgresql/s.pods\\?/..p) \
      -c postgresql-server \
      -- psql -U postgres
    ```

# Upgrading the app

Before upgrading, we recommend that you [back up all of your Superset data](#backup-uperset-data-to-your-local-workstation). For additional information about upgrading, visit the [superset documentation](https://superset.apache.org/docs/installation/upgrading-superset).

The [superset-docker](https://www.github.com/GoogleCloudPlatform/superset-docker) container running in the Superset StatefulSet is embedded with an upgrade script. To start the upgrade script, run the following command:

```shell
kubectl --namespace "${NAMESPACE}" exec -it "${POD_NAME}" --container superset -- pip install apache-superset --upgrade
```
# Uninstall the app

## Using the Google Cloud Console

1. In the Cloud Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of apps, select **Superset**.

1. On the Application Details page, click **Delete**.

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=superset-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend to use a kubectl version that is the same as the version of your cluster. Using the same versions of kubectl and the cluster helps avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

Alternately, you can delete the resources by using types and a label:

```shell
kubectl delete application \
  --namespace "${NAMESPACE}" \
  --selector "app.kubernetes.io/name=${APP_INSTANCE_NAME}"
```

### Delete the persistent volumes of your installation

By design, the removal of StatefulSets in Kubernetes does not remove the PersistentVolumeClaims that were attached to their Pods. This prevents your installations from accidentally deleting stateful data.

To remove the PersistentVolumeClaims along with their attached persistent disks, run the following `kubectl` commands:

```shell
# specify the variables values matching your installation:
export APP_INSTANCE_NAME=superset-1
export NAMESPACE=default

kubectl delete persistentvolumeclaims \
  --namespace "${NAMESPACE}" \
  --selector "app.kubernetes.io/name=${APP_INSTANCE_NAME}"
```

### Delete the GKE cluster

Optionally, if you no longer need the deployed app or the GKE cluster to which it is deployed, you can delete the cluster by running the following command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```
