# Overview

MariaDB is an open source relational database. It is a fork of MySQL.

MariaDB Galera Cluster is a synchronous multi-master cluster for MariaDB. It enables synchronous replication, multi-master topology, the ability to read and write to any cluster node, automatic membership control, the ability to drop failed nodes from the cluster, automatic node joining, true parallel replication, and more.

For more information on MariaDB, see the [MariaDB official website](https://mariadb.org/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

![Architecture diagram](resources/mariadb-galera-k8s-app-architecture.png)

The application offers stateful multi-instance MariaDB with Galera installation on a Kubernetes cluster.

MariaDB server runs in a StatefulSet with 3 replicas by default. The credentials for the administrator account are automatically generated and configured in the application through a Kubernetes Secret. The configuration files for the application (`/etc/mysql/mariadb.conf.d/`) are defined in a ConfigMap and mounted to the MariaDB StatefulSet.

By default, the Services exposing the MariaDB server are of type ClusterIP, which makes it accessible only in a private network on port 3306.

This application is pre-configured with an SSL certificate for internal communication between replicas. Before you make the app available to users, you must replace the pre-configured certificate with a valid certificate of your own.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this MariaDB app to a Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the [on-screen instructions](https://console.cloud.google.com/marketplace/details/google/mariadb-galera).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment. If you are using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your environment by default.

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

Create a new cluster from the command line:

```shell
export CLUSTER=mariadb-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo:

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components, such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.

The Application resource is defined by the [Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps) community. The source code can be found on [github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install MariaDB Galera Cluster

Navigate to the `mariadb-galera` directory:

```shell
cd click-to-deploy/k8s/mariadb-galera
```

#### Configure the environment variables

Choose an instance name and [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=mariadb-galera-1
export NAMESPACE=default
```

(Optional) Enable Stackdriver Metrics Exporter:

> **NOTE:** Your GCP project must have Stackdriver enabled. If you are using a non-GCP cluster, you cannot export metrics to Stackdriver.

By default, the application does not export metrics to Stackdriver. To enable this option, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=false
```

Configure the container image:

```shell
TAG=10.3
IMAGE_REPO="marketplace.gcr.io/google/mariadb-galera"
export IMAGE_MARIADB="${IMAGE_REPO}:${TAG}"
export IMAGE_MYSQL_EXPORTER="${IMAGE_REPO}/mysqld-exporter:${TAG}"
export IMAGE_METRICS_EXPORTER="${IMAGE_REPO}/prometheus-to-sd:${TAG}"
export IMAGE_PEER_FINDER="${IMAGE_REPO}/peer-finder:${TAG}"
```

The images above are referenced by [tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend that you pin each image to an immutable [content digest](https://docs.docker.com/registry/spec/api/#content-digests).  This ensures that the installed application always uses the same images, until you are ready to upgrade. To get the digest for the image, use the following script:

```shell
for i in "IMAGE_MARIADB" "IMAGE_MYSQL_EXPORTER" "IMAGE_METRICS_EXPORTER" "IMAGE_PEER_FINDER"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  echo ${!i};
done
```

Set the number of replicas for MariaDB Galera Cluster:

```shell
export REPLICAS=3
```

Configure the MariaDB user's credentials (passwords must be encoded in base64):

```shell
export MARIADB_ROOT_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1 | tr -d '\n' | base64)"
export EXPORTER_DB_PASSWORD="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1 | tr -d '\n' | base64)"
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "$NAMESPACE"
```

#### Create TLS certificates

To secure the connections between the primary and secondary instances, you must provide a certificate and private key, and apply them using Kubernetes Secrets.

1.  If you already have a certificate that you want to use, copy your
    certificate and key pair to the `/tmp/tls.crt`, and `/tmp/tls.key` files,
    then skip to the next step.

    To create a new certificate, run the following command:

    ```shell
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /tmp/tls.key \
        -out /tmp/tls.crt \
        -subj "/CN=mariadb/O=mariadb"
    ```

1.  Set the `TLS_CERTIFICATE_KEY` and `TLS_CERTIFICATE_CRT` variables:

    ```shell
    export TLS_CERTIFICATE_KEY="$(cat /tmp/tls.key | base64)"
    export TLS_CERTIFICATE_CRT="$(cat /tmp/tls.crt | base64)"
    ```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/mariadb-galera \
  --name "$APP_INSTANCE_NAME" \
  --namespace "$NAMESPACE" \
  --set "mariadb.image.repo=$IMAGE_REPO" \
  --set "mariadb.image.tag=$TAG" \
  --set "mariadb.volumeSize=8" \
  --set "db.rootPassword=$MARIADB_ROOT_PASSWORD" \
  --set "db.exporter.image=$IMAGE_MYSQL_EXPORTER" \
  --set "db.exporter.password=$EXPORTER_DB_PASSWORD" \
  --set "prometheusToSd.image=$IMAGE_METRICS_EXPORTER" \
  --set "prometheusToSd.enabled=$METRICS_EXPORTER_ENABLED" \
  --set "peerFinder.image=$IMAGE_PEER_FINDER" \
  --set "tls.base64EncodedPrivateKey=$TLS_CERTIFICATE_KEY" \
  --set "tls.base64EncodedCertificate=$TLS_CERTIFICATE_CRT" \
  --set "db.replicas=$REPLICAS" \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Platform Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

### Access MariaDB Galera Cluster within the network

You can connect to MariaDB without exposing it to public access, by using the `mysql` command line interface. You can connect directly to the MariaDB Pod, or use a client Pod.

#### Connect directly to the MariaDB Pod

Identify the MariaDB Pod using the following command:

```shell
kubectl get pods -o wide -l app.kubernetes.io/name=$APP_INSTANCE_NAME --namespace "$NAMESPACE"
```

Access MariaDB using the following command:

```shell
kubectl exec -it "$APP_INSTANCE_NAME-galera-0" --namespace "$NAMESPACE" -- mysql -h $APP_INSTANCE_NAME-galera-svc -p$(echo ${MARIADB_ROOT_PASSWORD} | base64 -d)
```

#### Connect to MariaDB using a client Pod

You can connect to the MariaDB server by using a client Pod that is based on the same MariaDB Docker image, by using the following command:

```shell
kubectl run -it --rm --image=$IMAGE_MARIADB --restart=Never mariadb-client -- mysql -h $APP_INSTANCE_NAME-galera-svc.$NAMESPACE.svc.cluster.local -p$(echo ${MARIADB_ROOT_PASSWORD} | base64 -d)
```

### Access the MariaDB service

Use port forwarding:

```shell
kubectl port-forward svc/$APP_INSTANCE_NAME-galera-svc --namespace $NAMESPACE 3306
```

# Application metrics

## Prometheus metrics

The application can be configured to expose its metrics through the
[MySQL Server Exporter](https://github.com/GoogleCloudPlatform/mysql-docker/tree/master/exporter)
in the
[Prometheus format](https://github.com/prometheus/docs/blob/master/content/docs/instrumenting/exposition_formats.md).
For more detailed information about setting up the plugin, see the
[Mysqld Exporter documentation](https://github.com/prometheus/mysqld_exporter/blob/master/README.md).

You can access the MySQL metrics at `[MYSQL-SERVICE]:9104/metrics`, where `[MYSQL-SERVICE]` is the
[Kubernetes Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services).

For example, to access the metrics locally, run the following command:

```shell
kubectl port-forward "svc/${APP_INSTANCE_NAME}-mysqld-exporter-svc" 9104 --namespace "${NAMESPACE}"
```

Then, navigate to [http://localhost:9104/metrics](http://localhost:9104/metrics).


### Configuring Prometheus to collect the metrics

Prometheus can be configured to automatically collect the application's metrics.
Follow the steps in
[Configuring Prometheus](https://prometheus.io/docs/introduction/first_steps/#configuring-prometheus).

You configure the metrics in the
[`scrape_configs` section](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config).

## Exporting metrics to Stackdriver

The deployment includes a [Prometheus to Stackdriver (`prometheus-to-sd`)](https://github.com/GoogleCloudPlatform/k8s-stackdriver/tree/master/prometheus-to-sd) container. If you enabled the option to export metrics to Stackdriver, the metrics are automatically exported to Stackdriver and visible in [Stackdriver Metrics Explorer](https://cloud.google.com/monitoring/charts/metrics-explorer).

Metrics are labeled with `app.kubernetes.io/name` consisting of application's name, which you define in the `APP_INSTANCE_NAME` environment variable.

The exporting option might not be available for GKE on-prem clusters.

> Note: Stackdriver has [quotas](https://cloud.google.com/monitoring/quotas) for the number of custom metrics created in a single GCP project. If the quota is met, additional metrics might not show up in the Stackdriver Metrics Explorer.

You can remove existing metric descriptors using
[Stackdriver's REST API](https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.metricDescriptors/delete).

# Scaling

## Scaling the cluster up or down

By default, the MariaDB Galera Cluster application is deployed using 3 replicas.
To change the number of replicas, use the following command:

```shell
REPLICAS=5
kubectl scale statefulsets "$APP_INSTANCE_NAME-galera" --namespace "$NAMESPACE" --replicas=$REPLICAS
```

where `REPLICAS` is the number of replicas you want.

Use the same command to reduce the number of replicas without disconnecting nodes from the cluster. When you reduce the number of replicas, the `PersistentVolumeClaims` in your StatefulSet remain unmodified.

# Backup and Restore

The following steps are based on the [MariaDB documentation](https://mariadb.com/kb/en/library/mysqldump/).

## Backup MariaDB data to your local workstation

To back up your MariaDB data, run the following command:

```shell
BKP_NAME="all-databases-$(date +%Y-%m-%d).sql.gz"
BKP_DIR=/var/mariadb/backup
POD_NAME=${APP_INSTANCE_NAME}-galera-0

# Backup database
kubectl -n ${NAMESPACE} exec -it ${POD_NAME} -c mariadb -- sh -c "mkdir -p ${BKP_DIR} && \
  mysqldump --all-databases --triggers --routines --events \
    --add-drop-table --single-transaction --ignore-table=mysql.user \
    -uroot -p\${MYSQL_ROOT_PASSWORD} \
    | gzip > ${BKP_DIR}/${BKP_NAME}"

# Copy backup file to local workstation and cleanup Pod
kubectl cp ${NAMESPACE}/${POD_NAME}:${BKP_DIR}/${BKP_NAME} ${BKP_NAME}
kubectl -n ${NAMESPACE} exec -it ${POD_NAME} -c mariadb -- sh -c "rm -f ${BKP_DIR}/${BKP_NAME}"
```

The backup will be stored in an `all-databases-<timestamp>.sql` file in the current directory of your local workstation.

> **WARNING**: Due to Galera cluster limitations, the `mysql.user` table is excluded from the backup.
If you wish to create full backup of all databases, you have to run `mysqldump` without `--ignore-table` option.
In that case you will not be able to restore it on Click to Deploy MariaDB Galera Cluster installation.
>
> To find out more, check official [Galera documentation](https://galeracluster.com/library/kb/trouble/user-changes.html).

## Restore MariaDB data on a running MariaDB instance

In order to restore MariaDB data, you must specify the location of the backup file:

```shell
BKP_FILE="[/path/to/backup_file].sql.gz"
```

Next, run the following commands to restore data from the specified backup:
```shell
POD_NAME=${APP_INSTANCE_NAME}-galera-0
BKP_DIR=/var/mariadb/backup
BKP_PATH=${BKP_DIR}/${BKP_FILE}

# restore all databases from provided backup
kubectl -n ${NAMESPACE} exec -it ${POD_NAME} -c mariadb -- sh -c "mkdir -p ${BKP_DIR}"
kubectl cp ${BKP_FILE} ${NAMESPACE}/${POD_NAME}:${BKP_PATH}
kubectl -n ${NAMESPACE} exec -it ${POD_NAME} -c mariadb -- bash -c "gunzip < ${BKP_PATH} |
    mysql -uroot -p\${MYSQL_ROOT_PASSWORD}"

# cleanup
kubectl -n ${NAMESPACE} exec -it ${POD_NAME} -c mariadb -- sh -c "rm -f ${BKP_PATH}"
```

# Upgrading the app

Before upgrading, we recommend that you back up your MariaDB database, using the [backup step](#backup-mariadb-data-to-your-local-workstation). For additional information about upgrades, see the [MariaDB documentation](https://mariadb.com/kb/en/library/upgrading/).

The MariaDB StatefulSet is configured to roll out updates automatically. Start the update by patching the StatefulSet with a new image reference:

```shell
IMAGE_MARIADB=[NEW_IMAGE_REFERENCE]
kubectl set image statefulset ${APP_INSTANCE_NAME}-galera --namespace ${NAMESPACE} "mariadb=${IMAGE_MARIADB}"
```

where `[NEW_IMAGE_REFERENCE]` is the Docker image reference of the new image that you want to use.

To check the status of Pods in the StatefulSet, and the progress of
the new image, run the following command:

```shell
kubectl get pods --selector app.kubernetes.io/name=${APP_INSTANCE_NAME} --namespace ${NAMESPACE}
```

# Uninstall the Application

## Using the Google Cloud Platform Console

1. In the GCP Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of applications, choose your application installation.

1. On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=mariadb-galera-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend using a `kubectl` version that is the same as the version of your cluster. Using the same versions of `kubectl` and the cluster helps avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

If you don't have the expanded manifest, delete the resources using types and a label:

```shell
kubectl delete application \
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
# specify the variables values matching your installation:
export APP_INSTANCE_NAME=mariadb-galera-1
export NAMESPACE=default

kubectl delete persistentvolumeclaims \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete the GKE cluster

Optionally, if you don't need the deployed application or the GKE cluster,
delete the cluster using this command:

```shell
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```
