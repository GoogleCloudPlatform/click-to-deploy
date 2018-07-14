# Overview

InfluxDB is an open source database for storing time series data. The source of time series data may come from logging and monitoring systems and IoT devices.

This is a single-instance version of InfluxDB. Multi-instance version of InfluxDB requires commercial license.

If you are interested in enterprise version of InfluxDB or you would like to learn more about InfluxDB in general, please, visit [InfluxDB website](https://www.influxdata.com/).

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

Navigate to the `influxdb` directory.

```shell
cd google-click-to-deploy/k8s/influxdb
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export APP_INSTANCE_NAME=influxdb-1
export NAMESPACE=default
```

Configure the container images.

```shell
export IMAGE_INFLUXDB="gcr.io/k8s-marketplace-eap/google/influxdb:latest"
```

Configure InfluxDB administrator account:

```shell
export INFLUXDB_ADMIN_USER=influxdb-admin
```

Configure password for InfluxDB administrator account (the value has to be encoded in base64)

```shell
export INFLUXDB_ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1 | tr -d '\n' | base64)
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
repo=`echo $IMAGE_INFLUXDB | cut -d: -f1`;
digest=`docker pull $IMAGE_INFLUXDB | sed -n -e 's/Digest: //p'`;
export $i="$repo@$digest";
env | grep $i;
```

#### Expand the manifest template

Use `envsubst` to expand the template. It is recommended that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_INFLUXDB $INFLUXDB_ADMIN_USER $INFLUXDB_ADMIN_PASSWORD' \
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

### Access InfluxDB (internally)

It is possible to connect to InfluxDB  without exposing it to public access and using `influx` tool.

Please, refer to [InfluxDB Getting Started](https://docs.influxdata.com/influxdb/v1.5/introduction/getting-started/)
for more information about `influx` usage and how to upload sample data to your InfluxDB instance.

#### Connect to InfluxDB via Pod

To do this, please identify InfluxDB's Pod using the following command:
```shell
kubectl get pods -o wide -l app.kubernetes.io/name=$APP_INSTANCE_NAME
```

Now, you can access InfluxDB using `influx` tool
```shell
kubectl exec -it "$APP_INSTANCE_NAME-influxdb-0" --namespace "$NAMESPACE" -- influx -host localhost -port 8086 -username <InfluxDB Admin username> -password <InfluxDB Admin user's password>
```

#### Connect to InfluxDB using `kubectl port-forward` method

This method assumes that you installed `influx` tool on your local machine. 
Please, refer to [InfluxDB installation instructions](https://docs.influxdata.com/influxdb/v1.5/introduction/installation/)
to learn how to do that.

You could also use a local proxy to access InfluxDB that is not exposed publicly. Run the following command in a separate background terminal:
```shell
 kubectl port-forward "${APP_INSTANCE_NAME}-influxdb-0" 8086:8086 --namespace "${NAMESPACE}"
 ```

Now, in your main terminal you can invoke `influx` tool as follows:
```shell
influx -host localhost -port 8086 -username <InfluxDB Admin username> -password <InfluxDB Admin user's password>
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

TODO by rafalbiegacz@ after merging

# Upgrade

This is single-instance InfluxDB solution:
- Upgrade will case some downtime of your application
- Configuration and data of InfluxDB will be retained.

This procudure assumes that you have a new image for InfluxDB container published and being available to your Kubernetes cluster. The new image is available at <url-pointing-to-new-image>.

Start with modification of the image used for pod temaplate within InfluxDB StatefulSet:

```shell
kubectl set image statefulset "$APP_INSTANCE_NAME-influxdb" \
  influxdb=<url-pointing-to-new-image>
```

where `<url-pointing-to-new-image>` is the new image.

To check the status of Pods in the StatefulSet and the progress of deployment of new image run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME
```

To check the current image used by pods within `InfluxDB` K8s application, you can run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' | sort
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
export APP_INSTANCE_NAME=influxdb-1
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

### Delete GKE cluster

Optionally, if you do not need both the deployed application and GKE cluster used for deployment then you can delete the whole GKE cluster using this command:

```shell
export CLUSTER=marketplace-cluster
export ZONE=us-west1-a
```

```
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```
