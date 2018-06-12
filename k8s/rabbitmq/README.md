# Overview

RabbitMQ is an open source messaging system that implements the Advanced
Message Queueing Protocol to serve a variety of messaging applications.

[Learn more](https://www.rabbitmq.com/)

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this RabbitMQ app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/rabbitmq).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command-line.

```shell
export PROJECT=your-gcp-project
export CLUSTER=marketplace-cluster
export ZONE=us-west1-a

gcloud --project "$PROJECT" container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to talk to the new cluster.

```shell
gcloud --project "$PROJECT" container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo.

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

Navigate to the `rabbitmq` directory.

```shell
cd click-to-deploy/k8s/rabbitmq
```

Do a one-time setup for your cluster to understand Application resources.

```shell
make crd/install
```

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `rabbitmq` directory.

```shell
cd click-to-deploy/k8s/rabbitmq
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export APP_INSTANCE_NAME=rabbitmq-1
export NAMESPACE=default
```

Set the number of replicas.

```shell
export REPLICAS=3
```

Set or generate the [Erlang cookie](https://www.rabbitmq.com/clustering.html#erlang-cookie). The cookie has be encoded in base64.

```shell
export RABBITMQ_ERLANG_COOKIE=$(openssl rand -base64 32)
```

Configure the container images.

```shell
export IMAGE_RABBITMQ="gcr.io/k8s-marketplace-eap/google/rabbitmq3:latest"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
for i in "IMAGE_RABBITMQ"; do
  repo=`echo ${!i} | cut -d: -f1`;
  digest=`docker pull ${!i} | sed -n -e 's/Digest: //p'`;
  export $i="$repo@$digest";
  env | grep $i;
done
```

#### Expand the manifest template

Use `envsubst` to expand the template. It is recommended that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_RABBITMQ $REPLICAS $RABBITMQ_ERLANG_COOKIE' \
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

### Expose RabbitMQ service

By default, the application does not have an external IP. Run the
following command to expose an external IP:

```
kubectl patch svc "$APP_INSTANCE_NAME-rabbitmq-svc" \
  --namespace "$NAMESPACE" \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

### Access RabbitMQ service

Get the external IP of the RabbitMQ service.

```
SERVICE_IP=$(kubectl get \
  --namespace ${NAMESPACE} \
  svc ${APP_INSTANCE_NAME}-rabbitmq-svc \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "http://${SERVICE_IP}"
```

Note that it might take some time for the external IP to be provisioned.

### Scale the cluster

By default, RabbitMQ K8s application is deployed using 3 replicas. You can manually scale it to deploy more replicas using the following command.

```
kubectl scale statefulsets "$APP_INSTANCE_NAME-rabbitmq" \
  --namespace "$NAMESPACE" --replicas=<new-replicas>
```
