# Overview

Open-source distributed event streaming platform used for high-performance data pipelines, streaming analytics, data integration, and mission-critical applications.

For more information on Apache Kafka, see the Apache Kafka [official website](https://kafka.apache.org/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

![Architecture diagram](resources/apache-kafka-k8s-app-architecture.png)

This solution is focused on Kafka Cluster mode which uses ZooKeeper for manage service discovery for Kafka Brokers. By default 3 replicas of Kafka broker nodes and 3 replicas of ZooKeeper nodes are deployed. For more information about Kafka visit [official documentation](https://kafka.apache.org/documentation/).

# Installation

Get up and running with a few clicks! To install this Kafka app to a Google
Kubernetes Engine (GKE) cluster by using Google Cloud Marketplace, follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/kafka).

## Command-line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/kafka)

### Prerequisites

#### Setting up command-line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, then `gcloud`, `kubectl`, Docker, and Git are installed in your
environment by default.

* [gcloud](https://cloud.google.com/sdk/gcloud/)
* [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
* [docker](https://docs.docker.com/install/)
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [openssl](https://www.openssl.org/)
* [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Creating a Google Kubernetes Engine (GKE) cluster

Create a new cluster from the command line:

```shell
export CLUSTER=kafka-cluster
export ZONE=us-west1-a
export PROJECT_ID=<GCP_Project_ID>

gcloud config set project ${PROJECT_ID}
gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Cloning this repo

Clone this repo, and the associated tools repo:

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Installing the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, StatefulSets, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following
command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.

The
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community defines the Application resource. You can find the source code at
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Installing the app

Navigate to the `kafka` directory:

```shell
cd click-to-deploy/k8s/kafka
```

#### Configuring the app with environment variables

Choose the instance name and namespace for the app. For most cases, you can
use the `default` namespace.

```shell
export APP_INSTANCE_NAME="kafka-1"
export NAMESPACE="default"
```
(Optional) Enable Stackdriver Metrics Exporter:

> **NOTE:** Your GCP project must have Stackdriver enabled. If you are using a
> non-GCP cluster, you cannot export metrics to Stackdriver.

By default, the application does not export metrics to Stackdriver. To enable
this option, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=false

```

Configure the image tag:

```shell
export TAG=3.4
```
Configure the container images:

```shell
IMAGE_REGISTRY="marketplace.gcr.io/google"
export IMAGE_KAFKA="${IMAGE_REGISTRY}/kafka"
export IMAGE_ZOOKEEPER="${IMAGE_REGISTRY}/kafka/zookeeper:${TAG}"
export IMAGE_EXPORTER="${IMAGE_REGISTRY}/kafka/exporter:${TAG}"
export IMAGE_DEPLOYER="${IMAGE_REGISTRY}/kafka/deployer:${TAG}"
export IMAGE_METRICS_EXPORTER="${IMAGE_REGISTRY}/kafka/prometheus-to-sd:${TAG}"
```
Set or generate the passwords:

```shell
# Set alias for password generation
alias generate_pwd="cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1 | tr -d '\n'"

# Kafka cluster credentials
export KAFKA_USER="kafka"
export KAFKA_PASSWORD="$(generate_pwd)"

```

Set the storage class for the persistent volume of Kafka nodes and ZooKeeper nodes:

 * Set the StorageClass name. You can select your existing StorageClass name for
   the persistent disk of Kafka application storage.
 * Set the persistent disk's size for Kafka storage. The default disk size is
   `10Gi`.
 * Set the persistent disk's size for ZooKeeper storage. The default disk size
   is `5Gi`.

```shell
export STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export PERSISTENT_KAFKA_SIZE="10Gi"
export PERSISTENT_ZK_SIZE="5Gi"
```

#### Creating a namespace in your Kubernetes cluster

If you use a different namespace than `default`, or if the namespace does
not exist yet, create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Expanding the manifest template

To expand the template, use `helm template`. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template "${APP_INSTANCE_NAME}" chart/kafka \
    --namespace "${NAMESPACE}" \
    --set kafka.image.repo="${IMAGE_KAFKA}" \
    --set kafka.image.tag="${TAG}" \
    --set kafka.kUser="${KAFKA_USER}" \
    --set kafka.kPassword="${KAFKA_PASSWORD}" \
    --set persistence.kafka.size="${PERSISTENT_KAFKA_SIZE}" \
    --set persistence.zookeeper.size="${PERSISTENT_ZK_SIZE}" \
    --set persistence.storageClass="${STORAGE_CLASS}" \
    --set exporter.image="${IMAGE_EXPORTER}" \
    --set zookeeper.image="${IMAGE_ZOOKEEPER}" \
    --set deployer.image="${IMAGE_DEPLOYER}" \
    --set metrics.image="${IMAGE_METRICS_EXPORTER}" \
    --set metrics.exporter.enabled="${METRICS_EXPORTER_ENABLED}" \
    > "${APP_INSTANCE_NAME}_manifest.yaml"
  ```

#### Applying the manifest to your Kubernetes cluster

To apply the manifest to your Kubernetes cluster, use `kubectl`:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```
### Accessing to the Kafka Service

The deployed service of Kafka Cluster is of type ClusterIP, so you can reach the Kafka service within a Kubernetes cluster by internal service.

To accomplish this, run the following commands:

```shell
# Get "kafka" user credentials of Kafka Cluster
KAFKA_USER=$(kubectl get secret --namespace \
            ${NAMESPACE} ${APP_INSTANCE_NAME}-kafka-secrets \
            -o jsonpath="{.data.kafka_user}" | base64 --decode)
KAFKA_PASSWORD=$(kubectl get secret --namespace \
            ${NAMESPACE} ${APP_INSTANCE_NAME}-kafka-secrets \
            -o jsonpath="{.data.kafka_password}" | base64 --decode)

echo "username: ${KAFKA_USER}"
echo "password: ${KAFKA_PASSWORD}"
```

After running the commands, run a test pod and install kafkacat util in the container with the following commands:

```shell
kubectl run --rm -i --tty kafkaclient \
        --namespace ${NAMESPACE} \
        --image=ubuntu --restart=Never \
        --env="APP_INSTANCE_NAME=${APP_INSTANCE_NAME}" \
        --env="KAFKA_USER=${KAFKA_USER}" \
        --env="KAFKA_PASSWORD=${KAFKA_PASSWORD}" \
        -- bash
```

Inside the container install kafkacat util
```shell
apt update
apt install -y kafkacat
```

After kafkacat util is installed, you can connect to the Kafka Cluster service with the following command:

```shell
# Inside the container run kafkacat command
kafkacat -L -b ${APP_INSTANCE_NAME}-kafka-client \
         -X sasl.mechanisms=PLAIN \
         -X security.protocol=SASL_PLAINTEXT  \
         -X sasl.username=${KAFKA_USER} \
         -X sasl.password=${KAFKA_PASSWORD}
```
### Interacting with Kafka Cluster via `kafkacat`
> Note: kafkaclient pod should be kept running



```shell
AUTH_OPTS="-X sasl.mechanisms=PLAIN \
         -X security.protocol=SASL_PLAINTEXT  \
         -X sasl.username=${KAFKA_USER} \
         -X sasl.password=${KAFKA_PASSWORD}"

# Check Cluster status and kafka broker list
kafkacat -L -b ${APP_INSTANCE_NAME}-kafka-client $AUTH_OPTS

# Send a message to a test topic
echo "Test from Kafkaclient" | kafkacat -P -b ${APP_INSTANCE_NAME}-kafka-client -t test $AUTH_OPTS

# Get message from test topic
kafkacat -b ${APP_INSTANCE_NAME}-kafka-client -t test -e $AUTH_OPTS

```


## Authentication and Security
This Kafka deployment use SASL authentication protocol for Kafka broker client authentication, there is not internal authentication enabled for the communication between Kafka brokers and ZooKeeper.

Those Java parameters should be passed to external clients which want to connect to Kafka. You can check this parameters by running below commands:
```shell
# Java option for basic auth
kubectl -n ${NAMESPACE} \
        exec -it ${APP_INSTANCE_NAME}-kafka-0 -c kafka \
        -- bash -c 'echo OPTIONS=\
        KAFKA_SASL_ENABLED_MECHANISMS=$KAFKA_SASL_ENABLED_MECHANISMS, \
        KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL=$KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL'

```

# Monitoring
Kafka image includes a Prometheus exporter to collect metrics and other data. In this solution seperate deployment and service used to access metrics. Exporter Deployment uses same Kafka image, connects to main Kafka Cluster and ZooKeeper service, exports metrics at 9308 port for `/metrics` endpoint.

> Visit [Kafka exporter for Prometheus project](https://github.com/danielqsj/kafka_exporter) for more information.

To check metrics from Kafka exporter service forward exporter service port to local machine
```shell
# Forward Kafka exporter service port to local workspace
kubectl port-forward svc/${APP_INSTANCE_NAME}-kafka-exporter --namespace ${NAMESPACE} 9308
```
Visit http://localhost:9308/metrics to see metrics from Kafka.

# Scaling

## Scaling the cluster up or down

By default, the Kafka distributed cluster starts with 3 replicas.

To change the number of replicas, use the following command, where `REPLICAS`
is your desired number of replicas:

```
export REPLICAS=4
kubectl scale statefulsets "${APP_INSTANCE_NAME}-kafka" \
        --namespace "${NAMESPACE}" --replicas="${REPLICAS}"
```

When this option is used to scale down a cluster, it reduces the number of
replicas without disconnecting nodes from the cluster. Scaling down also does
not affect the `PersistentVolumeClaims` of your `StatefulSet`.


# Upgrading the app

Before you upgrade the app, we recommend that you back up all of yourKafka brokers.
> Visit [Kafka Upgrade Notes](https://kafka.apache.org/documentation.html#upgrade) to check limitations for upgrading between versions

The Kafka StatefulSet is configured to roll out updates automatically. To
start the update, patch the StatefulSet with a new image reference, where
`[NEW_IMAGE_REFERENCE]` is the Docker image reference of the new image that you
want to use:

```shell
kubectl set image statefulset ${APP_INSTANCE_NAME}-kafka --namespace ${NAMESPACE} \
        "kafka=[NEW_IMAGE_REFERENCE]"
```

To check the status of Pods in the StatefulSet, and the progress of the
new image, run the following command:

```shell
kubectl get pods --selector app.kubernetes.io/name=${APP_INSTANCE_NAME} \
        --namespace ${NAMESPACE}
```
# Kafka Standalone mode
It is also possible to deploy this Kafka application as a standalone mode for testing purposes.
> Warning: This should not be used for production!

With Standalone mode enabled, instead of multiple ZooKeeper instances will create only one ZooKeeper instance and Kafka will be deployed with a single replica only.
Also no any authentication will be applied to the solution to make it easier for testing.

To deploy Kafka as a standalone mode, run following commands:
```shell
# Export necessary variables
APP_INSTANCE_NAME=kafka-standalone
NAMESPACE=default
STANDALONE_MODE_ENABLED=true
TAG="2.8"
IMAGE_REGISTRY="marketplace.gcr.io/google"
IMAGE_KAFKA="${IMAGE_REGISTRY}/kafka"
IMAGE_ZOOKEEPER="${IMAGE_REGISTRY}/kafka/zookeeper:${TAG}"
IMAGE_DEPLOYER="${IMAGE_REGISTRY}/kafka/deployer:${TAG}"
IMAGE_EXPORTER="${IMAGE_REGISTRY}/kafka/exporter:${TAG}"
STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
PERSISTENT_KAFKA_SIZE="2Gi"
PERSISTENT_ZK_SIZE="2Gi"
METRICS_EXPORTER_ENABLED=false

# Generate manifest file
helm template "${APP_INSTANCE_NAME}" \
    --namespace "${NAMESPACE}" \
    --set kafka.standalone="${STANDALONE_MODE_ENABLED}" \
    --set zookeeper.image="${IMAGE_ZOOKEEPER}" \
    --set kafka.image.repo="${IMAGE_KAFKA}" \
    --set kafka.image.tag="${TAG}" \
    --set deployer.image="${IMAGE_DEPLOYER}" \
    --set exporter.image="${IMAGE_EXPORTER}" \
    --set persistence.storageClass="${STORAGE_CLASS}" \
    --set persistence.kafka.storageSize="${PERSISTENT_KAFKA_SIZE}" \
    --set persistence.zookeeper.size="${PERSISTENT_ZK_SIZE}" \
    --set metrics.exporter.enabled="${METRICS_EXPORTER_ENABLED}" \
    chart/kafka > ${APP_INSTANCE_NAME}_manifest.yaml

# Apply the manifest file
kubectl apply -f "${APP_INSTANCE_NAME}_standalone_manifest.yaml" --namespace "${NAMESPACE}"
```

# Uninstalling the app

## Using the Google Cloud Console

1.  In the Cloud Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

2.  From the list of apps, click **Kafka**.

3.  From the **Application Details** page, click **Delete**.

## Using the command line

### Preparing your environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=kafka-1
export NAMESPACE=default
```

### Deleting the resources

> Note: We recommend using the version of `kubectl` that is the same as the
> version for your cluster. Using the same version for `kubectl` and the cluster
> helps to avoid unforeseen issues.

#### Deleting the deployment with the generated manifest file

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace ${NAMESPACE}
```

#### Deleting the deployment by deleting the Application resource

If you don't have the expanded manifest file, you can delete the
resources by using types and a label:

```shell
kubectl delete application,statefulset,secret,service,deployment,pdb,cm,jobs \
      --namespace ${NAMESPACE} \
      --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

Deleting the `Application` resource deletes all of your deployment's resources,
except for `PersistentVolumeClaim`. To remove the `PersistentVolumeClaim`s
with their attached persistent disks, run the following `kubectl` command:

```shell
kubectl delete persistentvolumeclaims \
      --namespace ${NAMESPACE} \
      --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```
