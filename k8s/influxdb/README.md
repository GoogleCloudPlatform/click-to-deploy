# Overview

InfluxDB is an open source database for storing time series data, such
as data from from logging and monitoring systems, or from IoT devices.

This is a single-instance version of InfluxDB. The multi--instance version of
InfluxDB requires a commercial license.

If you are interested in the enterprise version of InfluxDB visit the
[InfluxDB website](https://www.influxdata.com/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this InfluxDB app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/influxdb).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=influxdb-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to connect to the new cluster.

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo:

```shell
gcloud source repos clone google-click-to-deploy --project=k8s-marketplace-eap
gcloud source repos clone google-marketplace-k8s-app-tools --project=k8s-marketplace-eap
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, navigate to the
`k8s/vendor` folder in the repository, and run the following command:

```shell
kubectl apply -f google-marketplace-k8s-app-tools/crd/*
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps) community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `influxdb` directory:

```shell
cd google-click-to-deploy/k8s/influxdb
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=influxdb-1
export NAMESPACE=default
```

Configure the container image:

```shell
export IMAGE_INFLUXDB="gcr.io/k8s-marketplace-eap/google/influxdb:latest"
```

Configure the InfluxDB administrator account:

```shell
export INFLUXDB_ADMIN_USER=influxdb-admin
```

Configure password for InfluxDB administrator account (the value must be
encoded in base64)

```shell
export INFLUXDB_ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1 | tr -d '\n' | base64)
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images,
until you are ready to upgrade. To get the digest for the image, use the
following script:

```shell
repo=`echo $IMAGE_INFLUXDB | cut -d: -f1`;
digest=`docker pull $IMAGE_INFLUXDB | sed -n -e 's/Digest: //p'`;
export $i="$repo@$digest";
env | grep $i;
```

#### Expand the manifest template

Use `envsubst` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_INFLUXDB $INFLUXDB_ADMIN_USER $INFLUXDB_ADMIN_PASSWORD' \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

### Access InfluxDB (internally)

You connect to InfluxDB  without exposing it to public access, using the
`influx` tool.

For information about using `influx`, and steps to upload sample data
to your instance, see the [InfluxDB Getting Started guide](https://docs.influxdata.com/influxdb/v1.5/introduction/getting-started/).

#### Connect to the InfluxDB Pod

To identify the InfluxDB Pod, run the following command:

```shell
kubectl get pods -o wide -l app.kubernetes.io/name=$APP_INSTANCE_NAME --namespace "$NAMESPACE"
```

Now, you can access InfluxDB using the `influx` tool:

#### Connect to InfluxDB via Pod

To do this, please identify InfluxDB's Pod using the following command:

```shell
kubectl get pods -o wide -l app.kubernetes.io/name=$APP_INSTANCE_NAME --namespace "$NAMESPACE"
```

Now, you can access InfluxDB using `influx` tool

```shell
kubectl exec -it "$APP_INSTANCE_NAME-influxdb-0" --namespace "$NAMESPACE" -- influx -host localhost -port 8086 -username <admin username> -password <admin password>
```

#### Connect to InfluxDB using `kubectl port-forward` method

This method assumes that you installed `influx` tool on your local machine.
Please, refer to [InfluxDB installation instructions](https://docs.influxdata.com/influxdb/v1.5/introduction/installation/)
to learn how to do that.

You could also use a local proxy to access InfluxDB that is not exposed publicly. Run the following command in a separate background terminal:

```shell
 kubectl port-forward "${APP_INSTANCE_NAME}-influxdb-0" 8086 --namespace "${NAMESPACE}"
 ```

Now, in your main terminal you can invoke `influx` tool as follows:

```shell
influx -host localhost -port 8086 -username <admin username> -password <admin password>
```

### Access InfluxDB (externally)

This specific InfluxDB configuration was prepared to be used as internal component of your system,
e.g. as part of your log collection system consistig of Prometheus+InfluxDB+Grafana.

It is possible to expose InfluxDB to external world - it's not recommened though to do that without securing connection to the database with SSL/TLS.

In case you would like, anyway, to expose InfluxDB solution for testing purposes (for example) you can do that in the following way:

```
kubectl patch svc "$APP_INSTANCE_NAME-influxdb-svc" \
  --namespace "$NAMESPACE" \
  --patch '{"spec": {"type": "LoadBalancer"}}'
```

> **NOTE:** It might take some time for the external IP to be provisioned.

#### Extract IP addess

Get the external IP of InfluxDB instance using the following command:

#### Connect to InfluxDB in the Pod

Identify InfluxDB's Pod using the following command:

```shell
kubectl exec -it "$APP_INSTANCE_NAME-influxdb-0" --namespace "$NAMESPACE" -- influx -host localhost -port 8086 -username [ADMIN_USERNAME] -password [ADMIN_PASSWORD]
```
#### Connect to InfluxDB using port forwarding

Before you begin, [install `influx`](https://docs.influxdata.com/influxdb/v1.5/introduction/installation/) on your local machine.

In a background terminal, run the following command :

```shell
 kubectl port-forward "${APP_INSTANCE_NAME}-influxdb-0" 8086 --namespace "${NAMESPACE}"
 ```

Now, in your main terminal, run the `influx` tool:

```shell
influx -host localhost -port 8086 -username [ADMIN_USERNAME] -password [ADMIN_PASSWORD]
```

### Access InfluxDB (externally)

This InfluxDB configuration was prepared to be used as internal component of
your system, for example, as part of a log collection system with Prometheus,
InfluxDB, and Grafana.

If you want to open your InfluxDB application externally, we recommend that
you secure the connection to the database with SSL/TLS.

To get an external IP address for InfluxDB, run the following command:

```
kubectl patch svc "$APP_INSTANCE_NAME-influxdb-svc" \
  --namespace "$NAMESPACE" \
  --patch '{"spec": {"type": "LoadBalancer"}}'
```

It might take some time to create the external IP address.

#### Get the external IP address

Get the external IP of InfluxDB instance using the following command:

```shell
INFLUXDB_IP=$(kubectl get svc $APP_INSTANCE_NAME-influxdb-svc \
  --namespace $NAMESPACE \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo $INFLUXDB_IP
```

# Scaling

This is a single-instance version of InfluxDB. You cannot scale it.

If you are interested in multi-instance/enterprise version of InfluxDB, please, visit [InfluxDB website](https://www.influxdata.com/).

# Backup and Restore

The following steps are based on the [InfluxDB documentation](https://docs.influxdata.com/influxdb/v1.5/administration/backup_and_restore/).

For backing up and restoring the database, use the `influxd backup` and `influxd restore` commands respectively.

To access the admin interface for InfluxDB, you need connectivity on port 8088.

Before you begin, create an `influxdb-backup` directory on your local
computer, and make sure that is empty.

## Backup InfluxDB data to your local computer

Navigate to the `influxdb/scripts` directory:

```shell
cd google-click-to-deploy/k8s/influxdb/scripts
```

Run the `make_backup.sh` script, passing the name of your InfluxDB instance as
an argument.
```shell
./make_backup.sh $APP_INSTANCE_NAME $NAMESPACE [BACKUP_FOLDER]
```

The backup is stored in the `influxdb-backup` directory on your local
computer.

## Restore InfluxDB data on running InfluxDB instance

Navigate to the `influxdb/scripts` directory:

```shell
cd google-click-to-deploy/k8s/influxdb/scripts
```

Run the `make_restore.sh` script, passing the name of your InfluxDB instance
as an argument.
```shell
./make_restore.sh $APP_INSTANCE_NAME $NAMESPACE [BACKUP_FOLDER]
```

The data is restored from the backup in the `influxdb-backup` directory on
your local computer.

# Upgrading the app

Because this is a single-instance InfluxDB solution, note that an upgrade
causes some downtime for your application. Your InfluxDB configuration and
data are retained after the upgrade.

This procudure assumes that you have a new image for InfluxDB container published and being available to your Kubernetes cluster. The new image is
used in the commands below as `[NEW_IMAGE_REFERENCE]`.

In the InfluxDB StatefulSet, modify the image used for the Pod template:

```shell
kubectl set image statefulset "$APP_INSTANCE_NAME-influxdb" \
  influxdb=[NEW_IMAGE_REFERENCE]
```

where `[NEW_IMAGE_REFERENCE]` is the new image.

To check the status of Pods in the StatefulSet and the progress of deploying
the new image, run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME
```

To check the current image used by Pods in the application, run the following
command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' | sort
```

# Uninstall the Application

## Using the Google Cloud Platform Console

1. In the GCP Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of applications, click **InfluxDB**.

1. On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=influxdb-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** You must use a kubectl version that is the same, or later, as the version of your cluster. Using the latest version of kubectl helps avoid unforeseen issues.

To to delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

Otherwise, delete the resources using types and a label:

```shell
kubectl delete statefulset,service \
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
export APP_INSTANCE_NAME=influxdb-1
export NAMESPACE=default

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
