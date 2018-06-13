# Overview

Elasticsearch is an open-source search engine that provides a distributed, multitenant-capable
full-text search engine with an HTTP web interface and schema-free JSON documents..

[Learn more](https://www.elastic.co/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Elasticsearch app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/elasticsearch).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)

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
gcloud container clusters get-credentials "$CLUSTER"
```

#### Clone this repo

Clone this repo and the associated tools repo.

```shell
gcloud source repos clone google-click-to-deploy --project=k8s-marketplace-eap
gcloud source repos clone google-marketplace-k8s-app-tools --project=k8s-marketplace-eap
```

#### Install the Application resource definition

Do a one-time setup for your cluster to understand Application resources.

```shell
kubectl apply -f google-marketplace-k8s-app-tools/crd/*
```

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `elasticsearch` directory.

```shell
cd google-click-to-deploy/k8s/elasticsearch
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export NAME=elasticsearch-1
export NAMESPACE=default
```

Optionally, define how many pods should be run in StatefulSet.
If not specified, it will default to 2.

```shell
export REPLICAS=2
```

#### Use `make` to install your application

`make` will build a deployer container image and then run your installation:

```shell
make app/install
```

#### View the app in the Google Cloud Console

Point your browser to:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

### Expose Elasticsearch service

By default, the application does not have an external IP. Run the
following command to expose an external IP:

```
kubectl patch svc "$APP_INSTANCE_NAME-elasticsearch-svc" \
  --namespace "$NAMESPACE" \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

### Access Elasticsearch service

Get the external IP of the Elasticsearch service and visit
the URL printed below in your browser.

```
SERVICE_IP=$(kubectl get \
  --namespace ${NAMESPACE} \
  svc ${APP_INSTANCE_NAME}-elasticsearch-svc \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "http://${SERVICE_IP}:9200"
```

Note that it might take some time for the external IP to be provisioned.

### Scale the cluster

Scale the number of master node replicas by the following command:

```
kubectl scale statefulsets "$APP_INSTANCE_NAME-elasticsearch" \
  --namespace "$NAMESPACE" --replicas=<new-replicas>
```

By default, there are 2 replicas to satisfy the minimum master quorum.
To increase resilience, it is recommended to scale the number of replicas
to at least 3.

For more information about the StatefulSets scaling, check the
[Kubernetes documentation](https://kubernetes.io/docs/tasks/run-application/scale-stateful-set/#kubectl-scale).


### Uninstall the Application

#### Using GKE UI

Navigate to `GKE > Applications` in GCP console. From the list of applications, click on the one
that you wish to uninstall.

On the new screen, click on the `Delete` button located in the top menu. It will remove
the resources attached to this application.

#### Using the command line

Make sure your environment variable point to values matching the installation:

```shell
export NAME=elasticsearch-1
export NAMESPACE=default
```

Then run `make` command to remove the resources created by your installation:

```shell
make app/uninstall
```

#### Delete the persistent volumes of your installation

By design, removal of StatefulSets in Kubernetes does not remove the PersistentVolumeClaims that
were attached to their Pods. It protects your installations from mistakenly deleting stateful data.

If you wish to remove the PersistentVolumeClaims with their attached persistent disks, run the
following `kubectl` command:

```shell
# specify the variables values matching your installation:
export NAME=elasticsearch-1
export NAMESPACE=default

kubectl delete persistentvolumeclaims \
  --namespace $NAMESPACE
  --selector app.kubernetes.io/name=$NAME
```