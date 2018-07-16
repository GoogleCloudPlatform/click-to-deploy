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
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

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

Navigate to the `wordpress` directory.

```shell
cd google-click-to-deploy/k8s/wordpress
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export APP_INSTANCE_NAME=wordpress-1
export NAMESPACE=default
```

Configure the container images.

```shell
export IMAGE_WORDPRESS="gcr.io/k8s-marketplace-eap/google/wordpress:latest"
export IMAGE_MYSQL="gcr.io/k8s-marketplace-eap/google/wordpress/mysql:latest"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
for i in "IMAGE_WORDPRESS" "IMAGE_MYSQL"; do
  repo=`echo ${!i} | cut -d: -f1`;
  digest=`docker pull ${!i} | sed -n -e 's/Digest: //p'`;
  export $i="$repo@$digest";
  env | grep $i;
done
```

Set or generate passwords:

```shell
# If not installed pwgen previously, run:
sudo apt-get install -y pwgen base64

export ROOT_DB_PASSWORD="$(pwgen 16 1 | tr -d '\n' | base64)"
export WORDPRESS_DB_PASSWORD="$(pwgen 16 1 | tr -d '\n' | base64)"
```

#### Expand the manifest template

Use `envsubst` to expand the template. It is recommended that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_WORDPRESS $IMAGE_MYSQL $ROOT_DB_PASSWORD $WORDPRESS_DB_PASSWORD' \
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

### Expose WordPress service

By default, the application does not have an external IP. Run the
following command to expose an external IP:

```
kubectl patch svc "$APP_INSTANCE_NAME-wordpress-svc" \
  --namespace "$NAMESPACE" \
  --patch '{"spec": {"type": "LoadBalancer"}}'
```

### Access WordPress site

Get the external IP of the WordPress site service and visit
the URL printed below in your browser.

```
SERVICE_IP=$(kubectl get svc $APP_INSTANCE_NAME-wordpress-svc \
  --namespace $NAMESPACE \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "http://${SERVICE_IP}"
```

Note that it might take some time for the external IP to be provisioned.

### Set up WordPress

After accessing the WordPress main page, you will see the installation wizard.
Follow the instructions presented on the screen to finish the process.

# Scaling

This is a single-instance version of WordPress. You cannot scale it.

# Backup and restore

## Using WordPress plugins

Using one of the available plugins for WordPress backups is probably the most convenient way to
protect your data from loss. Nevertheless, there is a large variety of choices, when selecting
the right plugin for backups, including both paid and free options.

Topics to consider when selecting a backup plugin should include:
* *scope of backup* - your installation will contain not only media files or database data,
  but also themes, plugins and configurations; check if the plugin supports backing up all of them;
* *schedule and manual triggering* - does the plugin perform regular backups with a schedule
  that you can define and does it allow to trigger backup manually (for instance, before updating
  the installation or just after finishing a large update to your configuration);
* *location to store data* - your backup data should not be stored on the same server as your
  installation; one of the options to secure your backup data from accidental loss might be
  using a cloud provider - like Google Cloud Storage or Google Drive.

## Backup without a plugin

Backing up data directly from the server gives you full control over the schedule and scope of
backup, but is recommended only to advanced users.

We will cover a scenario for backing up WordPress database and all installation files, including
media content, themes and plugins. It is recommended to export the backup files to Google Cloud
Storage to secure the data in an independent location.

### Setup local environment

Setup environment variables to match with your WordPress installation:

```shell
export APP_INSTANCE_NAME=wordpress-1
export NAMESPACE=default
```

### Establish MySQL connection

For backing up WordPress database, you will need to have connection to MySQL host and port.
You can setup a local proxy with the following `kubectl` command in background:

```shell
kubectl port-forward "svc/${APP_INSTANCE_NAME}-mysql-svc" 3306 --namespace "${NAMESPACE}"
```

### Create backup

Backup procedure will require `mysql-client` package. To install it on Debian, run:

```shell
sudo apt-get install mysql-client
```

The following command creates WordPress database and files backup and saves the backup
archive as specified by `backup-file`:

```shell
backup_time="$(date +%Y%m%d-%H%M%S)"

# All parameters except --app and --namespace are optional.
scripts/backup.sh --app $APP_INSTANCE_NAME --namespace $NAMESPACE \
  --mysql-host 127.0.0.1 --mysql-port 3306 \
  --backup-file "wp-backup-${backup_time}.tar.gz"
```

### Secure your backup files

It is recommended to store your backup files in an independent and reliable location like
Google Cloud Storage (GCS) buckets. Read the [official documentation](https://cloud.google.com/storage/docs/creating-buckets)
to learn more about creating GCS buckets, setting permissions and uploading files.

## Restore

For restore procedure we assume that you already have your local environment populated with
variables of `APP_INSTANCE_NAME` and `NAMESPACE` pointing to WordPress installation and
established a MySQL connection.

### Restore WordPress database and files from backup

Run the script:

```shell
# Required: --app, --namespace and --backup-file.
scripts/restore.sh --app $APP_INSTANCE_NAME --namespace $NAMESPACE \
  --backup-file "wp-backup-${backup_time}.tar.gz" \
  --mysql-host 127.0.0.1 --mysql-port 3306
```

At first, it will automatically create backups of current database and filesystem of your WordPress
installation (they will not be deleted automatically by the script). Then the database will be
restored from an SQL dump and WordPress files will be replaced with the ones from the backup file.

# Upgrade the Application

## Prepare the environment

We recommend to create backup of your data before starting the upgrade procedure
(TODO - create and link Backup and restore chapter).

Please keep in mind that during the upgrade procedure your WordPress site will be unavailable.

Set your environment variables to match the installation properties:

```shell
export APP_INSTANCE_NAME=wordpress-1
export NAMESPACE=default
```

## Upgrade WordPress

Set the new image version in an environment variable:

```shell
export IMAGE_WORDPRESS=launcher.gcr.io/google/wordpress4-php7-apache:latest
```

Update the StatefulSet definition with new image reference:

```shell
kubectl patch statefulset $APP_INSTANCE_NAME-wordpress \
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
kubectl get pods "$APP_INSTANCE_NAME-wordpress-0" \
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
kubectl patch statefulset $APP_INSTANCE_NAME-mysql \
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
kubectl get pods $APP_INSTANCE_NAME-mysql-0 --namespace $NAMESPACE --watch
```

The pod should terminated and recreated with new image for `mysql` container. The final state of
the pod should be `Running` and marked as 1/1 in `READY` column.

To check the current image used for `mysql` container, you can run the following command:

```shell
kubectl get pod $APP_INSTANCE_NAME-mysql-0 \
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

### Delete the resources

> **NOTE:** Please keep in mind that `kubectl` guarantees support for Kubernetes server in +/- 1 versions.
> It means that for instance if you have `kubectl` in version 1.10.&ast; and Kubernetes 1.8.&ast;,
> you may experience incompatibility issues, like not removing the StatefulSets with
> apiVersion of apps/v1beta2.

If you still have the expanded manifest file used for the installation, you can use it to delete the resources.
Run `kubectl` on expanded manifest file matching your installation:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

Otherwise, delete the resources by indication of types and a label:

```shell
kubectl delete statefulset,secret,service \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```
### Delete the persistent volumes of your installation

By design, removal of StatefulSets in Kubernetes does not remove the PersistentVolumeClaims that
were attached to their Pods. It protects your installations from mistakenly deleting stateful data.

If you wish to remove the PersistentVolumeClaims with their attached persistent disks, run the
following `kubectl` commands:

```shell
# specify the variables values matching your installation:
export APP_INSTANCE_NAME=wordpress-1
export NAMESPACE=default

kubectl delete persistentvolumeclaims \
  --namespace $NAMESPACE
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
