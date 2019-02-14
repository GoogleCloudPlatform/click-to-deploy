# Overview

Prometheus is a monitoring toolkit. In this application it collects the metrics from a Kubernetes
cluster to which the application is deployed and presents them in pre-configured dashboard of
Grafana. Additionally, it allows to configure the alerting rules served automatically by Prometheus
Alert Manager.

[Learn more](https://prometheus.io/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

## Design

![Architecture diagram](resources/prometheus-grafana-architecture.png)

The application is designed to automatically collect metrics from Kubernetes cluster, collect them
in the Prometheus server and present in Grafana.

* **Prometheus StatefulSet** - collects all the configured metrics in pull model (by querying
  all the configured sources periodically). Each Prometheus Pod stored its data in
  a PersistentVolumeClaim.

* **Prometheus Node Exporter DaemonSet** - runs a Pod on each Kubernetes cluster node and collects
  node's metrics related to hardware and the operating system - by monitoring the host filesystem
  at `/proc` and `/sys`. The metrics are exposed on port 9100 of Node Exporter's Pods.

* **Kube State Metrics Deployment** - listens to the Kubernetes API server and produces metrics
  related to resources (deployments, nodes, pods, etc.). It exposes the metrics on HTTP endpoint
  `/metrics` on port 8080. Prometheus server consumes the metrics.

* **Prometheus Alert Manager** - receives the alerts raised by the Prometheus server and handles
  them accordingly to its configuration, specified in a ConfigMap.

* **Grafana StatefulSet** - provides a user interface for querying Prometheus about the metrics
  and visualizes the metrics in pre-configured dashboards.

## Configuration

* Prometheus server is deployed to a custom-size stateful set with the number of replicas specified
  by the user before installation. The configuration for Prometheus jobs, rules and alerts is
  stored in a ConfigMap.

* Kube State Metrics comes with a default-size deployment of one replica, but it includes
  a resizer addon monitoring the actual resources necessary to maintain the operations and
  dynamically rescaling the deployment.

* Prometheus Alert Manager - the application comes with a very simple configuration, including only
  the default receiver and simple grouping rules. To customize the configuration, edit the ConfigMap
  and recreate the Pods. Alert Manager StatefulSet is currently configured to spin up 2 replicas -
  if you are going to change it, adjust the `--mesh.peer` arguments of Alert Manager containers.

* Grafana StatefulSet - all the pre-configured dashboards of Grafana are stored in a ConfigMap.
  The StatefulSet is currently configured to have just one replica - the configuration does not
  currently allow to scale this number up.

* Each StatefulSet, Deployment and DaemonSet uses its own dedicated service
  account with permissions set accordingly to its expected functionality.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Prometheus app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/prometheus).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local workstation in the
future instructions.

<a target="_blank" href="https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_working_dir=k8s/prometheus"><img alt="Open in Cloud Shell" src ="http://gstatic.com/cloudssh/images/open-btn.svg"></a>

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

Create a new cluster from the command line:

```shell
export CLUSTER=prometheus-cluster
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

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `prometheus` directory:

```shell
cd click-to-deploy/k8s/prometheus
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app:

```shell
export APP_INSTANCE_NAME=prometheus-1
export NAMESPACE=default
```

Specify the number of replicas for the Prometheus cluster:

```shell
export PROMETHEUS_REPLICAS=2
```

Configure the container images:

```shell
TAG=2.2
export IMAGE_PROMETHEUS="marketplace.gcr.io/google/prometheus:${TAG}"
export IMAGE_ALERTMANAGER="marketplace.gcr.io/google/prometheus/alertmanager:${TAG}"
export IMAGE_KUBE_STATE_METRICS="marketplace.gcr.io/google/prometheus/kubestatemetrics:${TAG}"
export IMAGE_NODE_EXPORTER="marketplace.gcr.io/google/prometheus/nodeexporter:${TAG}"
export IMAGE_GRAFANA="marketplace.gcr.io/google/prometheus/grafana:${TAG}"
export IMAGE_PROMETHEUS_INIT="marketplace.gcr.io/google/prometheus/debian9:${TAG}"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images,
until you are ready to upgrade. To get the digest for the image, use the
following script:

```shell
for i in "IMAGE_PROMETHEUS" \
         "IMAGE_ALERTMANAGER" \
         "IMAGE_KUBE_STATE_METRICS" \
         "IMAGE_NODE_EXPORTER" \
         "IMAGE_GRAFANA" \
         "IMAGE_PROMETHEUS_INIT"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```

Generate a random password for Grafana:

```shell
# Install pwgen and base64
sudo apt-get install -y pwgen base64

# Set the Grafana password
export GRAFANA_GENERATED_PASSWORD="$(pwgen 12 1 | tr -d '\n' | base64)"
```

Define the size of Prometheus StatefulSet:

```shell
export PROMETHEUS_REPLICAS=2
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "$NAMESPACE"
```

#### Create service accounts

##### Make sure you are a Cluster Admin

Creating custom cluster roles requires being a Cluster Admin. To assign
the Cluster Admin role to your user account, run the following command:

```shell
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)
```

##### Create dedicated service accounts

Define the service accounts variables:

```shell
export PROMETHEUS_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-prometheus"
export KUBE_STATE_METRICS_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-kube-state-metrics"
export ALERTMANAGER_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-alertmanager"
export GRAFANA_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-grafana"
export NODE_EXPORTER_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-node-exporter"
```

Expand the manifest for service accounts creation:

```shell
cat resources/service-accounts.yaml \
  | envsubst '$NAMESPACE $PROMETHEUS_SERVICE_ACCOUNT $KUBE_STATE_METRICS_SERVICE_ACCOUNT $ALERTMANAGER_SERVICE_ACCOUNT $GRAFANA_SERVICE_ACCOUNT $NODE_EXPORTER_SERVICE_ACCOUNT' \
  > "${APP_INSTANCE_NAME}_sa_manifest.yaml"
```

Create the accounts on the cluster with `kubectl`:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_sa_manifest.yaml" \
  --namespace "${NAMESPACE}"
```

#### Expand the application manifest template

Use `envsubst` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
awk 'FNR==1 {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_PROMETHEUS $IMAGE_ALERTMANAGER $IMAGE_KUBE_STATE_METRICS $IMAGE_NODE_EXPORTER $IMAGE_GRAFANA $IMAGE_PROMETHEUS_INIT $NAMESPACE $GRAFANA_GENERATED_PASSWORD $PROMETHEUS_REPLICAS $PROMETHEUS_REPLICAS $PROMETHEUS_SERVICE_ACCOUNT $KUBE_STATE_METRICS_SERVICE_ACCOUNT $ALERTMANAGER_SERVICE_ACCOUNT $GRAFANA_SERVICE_ACCOUNT $NODE_EXPORTER_SERVICE_ACCOUNT' \
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

To view your app, open the URL in your browser.

# Access the Grafana UI

Grafana is exposed as a ClusterIP-only Service, `$APP_INSTANCE_NAME-grafana`.
To connect to the Grafana UI, you can either expose a public service endpoint, or keep it private and connect from you local environment with `kubectl port-forward`.

## Expose Grafana service externally

To expose Grafana with an external IP address, run the following command:

```shell
kubectl patch svc "$APP_INSTANCE_NAME-grafana" \
  --namespace "$NAMESPACE" \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

It might take a while for the external IP address to be created.

Get the public IP address with the following command:

```shell
SERVICE_IP=$(kubectl get svc $APP_INSTANCE_NAME-grafana \
  --namespace $NAMESPACE \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "http://${SERVICE_IP}/"
```

## Forward Grafana port in local environment

As an alternative to exposing Grafana publicly, use local port forwarding.
In a terminal, run the following command:

```shell
kubectl port-forward --namespace ${NAMESPACE} ${APP_INSTANCE_NAME}-grafana-0 3000
```

You can access the Grafana UI at `http://localhost:3000/`.

## Login to Grafana

Grafana requires authentication. To check your username and password, run the following commands:

```shell
GRAFANA_USERNAME="$(kubectl get secret $APP_INSTANCE_NAME-grafana \
                      --namespace $NAMESPACE \
                      --output=jsonpath='{.data.admin-user}' | base64 --decode)"
GRAFANA_PASSWORD="$(kubectl get secret $APP_INSTANCE_NAME-grafana \
                      --namespace $NAMESPACE \
                      --output=jsonpath='{.data.admin-password}' | base64 --decode)"
echo "Grafana credentials:"
echo "- user: ${GRAFANA_USERNAME}"
echo "- pass: ${GRAFANA_PASSWORD}"
```
