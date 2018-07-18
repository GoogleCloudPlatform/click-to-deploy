# Overview

Prometheus is a monitoring toolkit. This application consists of:

1.  **Prometheus** - the server for metrics.
1.  **Node Exporter** - monitoring agent for exposing per-node metrics.
1.  **Alert Manager** - a manager for alerts.
1.  **Grafana** - the monitoring UI.

[Learn more](https://prometheus.io/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Prometheus app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/prometheus).

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

To set up your cluster to understand Application resources, navigate to the
`k8s/vendor` folder in the repository, and run the following command:

```shell
kubectl apply -f marketplace-tools/crd/*
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
export IMAGE_PROMETHEUS="gcr.io/k8s-marketplace-eap/google/prometheus:${TAG}"
export IMAGE_ALERTMANAGER="gcr.io/k8s-marketplace-eap/google/prometheus/alertmanager:${TAG}"
export IMAGE_KUBE_STATE_METRICS="gcr.io/k8s-marketplace-eap/google/prometheus/kubestatemetrics:${TAG}"
export IMAGE_NODE_EXPORTER="gcr.io/k8s-marketplace-eap/google/prometheus/nodeexporter:${TAG}"
# TODO(khajduczenia): Add pushgateway to Makefile.
export IMAGE_PUSHGATEWAY="gcr.io/k8s-marketplace-eap/google/prometheus/pushgateway:${TAG}"
export IMAGE_GRAFANA="gcr.io/k8s-marketplace-eap/google/prometheus/grafana:${TAG}"
export IMAGE_PROMETHEUS_INIT="gcr.io/k8s-marketplace-eap/google/prometheus/debian9:${TAG}"
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
         "IMAGE_PUSHGATEWAY" \
         "IMAGE_GRAFANA" \
         "IMAGE_PROMETHEUS_INIT"; do
  repo=$(echo ${!i} | cut -d: -f1);
  digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
  export $i="$repo@$digest";
  env | grep $i;
done
```

#### Expand the manifest template

Use `envsubst` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_PROMETHEUS $IMAGE_ALERTMANAGER $IMAGE_KUBE_STATE_METRICS $IMAGE_NODE_EXPORTER $IMAGE_PUSHGATEWAY $IMAGE_GRAFANA $IMAGE_PROMETHEUS_INIT $NAMESPACE  $REPLICAS' \
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
  -p '{"spec": {"type": "LoadBalancer"}}
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
