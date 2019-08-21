# Overview

Consul is a distributed high availability solution based on Raft consensus algorithm which provide services and
node discovery, health checks, and distributed key values storage. It offers users many different ways to manage
infrastructure and content consistency. Also it allows to gather information about nodes.

For more information on Consul, see the [Consul official website](https://www.consul.io/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

## Design

![Architecture diagram](resources/consul-k8s-app-architecture.png)

The application offers stateful multi instance Consul cluster installation on a Kubernetes cluster.

Application consists of StatefulSet for consul servers and DaemonSet for consul clients for each Kubernetes cluster node.
User can specify number of consul servers instances. Default and recommend value is 3.

This application has optional support for gossip encryption between consul
servers and clients.

Optionally user can enable Prometheus exporter to export metrics to Stackdriver.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Consul app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/consul).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:

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
export CLUSTER=consul-cluster
export ZONE=us-west1-a

gcloud container clusters create "${CLUSTER}" --zone "${ZONE}"
```

Configure `kubectl` to connect to the new cluster.

```shell
gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}"
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
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps) community.
The source code can be found on [github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `consul` directory:

```shell
cd click-to-deploy/k8s/consul
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=consul-1
export NAMESPACE=default
```

Configure the container image:

```shell
TAG=1.4.4
export IMAGE_CONSUL="marketplace.gcr.io/google/consul:${TAG}"
export IMAGE_CONSUL_EXPOTER="marketplace.gcr.io/google/consul/exporter:${TAG}"
export IMAGE_METRICS_EXPORTER="marketplace.gcr.io/google/consul/prometheus-to-sd:${TAG}"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). We recommend
that you pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This ensures that the installed application always uses the same images,
until you are ready to upgrade. To get the digest for the image, use the
following script:

```shell
for i in "IMAGE_CONSUL" "IMAGE_CONSUL_EXPORTER" "IMAGE_METRICS_EXPORTER"; do
repo=$(echo ${!i} | cut -d: -f1);
digest=$(docker pull ${!i} | sed -n -e 's/Digest: //p');
export $i="$repo@$digest";
echo ${!i};
done
```

Optionally you can set the number of replicas for Consul:
Default and recommended value is 3. Minimum is 1.

```shell
export REPLICAS=3
```

Set consul domain and datacenter

```shell
exprot CONSUL_DOMAIN=consul
export CONSUL_DATACENTER=dc1
```

Enable Prometheus sidecar exporter

```shell
export PROMETHEUS_EXPORTER=true
```

Optionally create and configure gossip encryption key for Consul:

```shell
export CONSUL_GOSSIP_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 | tr -d '\n' | base64)
```

Optional you can set resources limits and requests for Consul client and server.
All options are optional.

```shell
export SERVER_RESOURCES_LIMITS_CPU=200m
export SERVER_RESOURCES_LIMITS_MEMORY=300Mi
export SERVER_RESOURCES_REQUESTS_CPU=100m
export SERVER_RESOURCES_REQUESTS_MEMORY=150Mi

export CLIENT_RESOURCES_LIMITS_CPU=200m
export CLIENT_RESOURCES_LIMITS_MEMORY=300Mi
export CLIENT_RESOURCES_REQUESTS_CPU=100m
export CLIENT_RESOURCES_REQUESTS_MEMORY=150Mi
```

Optionally you can define server storage capacity. Default value is 10Gi

```shell
export SERVER_STORAGE=10Gi
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

##### Create dedicated Service Accounts

Define the environment variables:

```shell
export CONSUL_CLIENT_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-consul-client"
export CONSUL_SERVER_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-consul-server"
```

Expand the manifest to create Service Accounts:

```shell
cat resources/service-accounts.yaml \
  | envsubst '${APP_INSTANCE_NAME} \
              ${CONSUL_CLIENT_SERVICE_ACCOUNT} \
              ${CONSUL_SERVER_SERVICE_ACCOUNT}' \
    > "${APP_INSTANCE_NAME}_sa_manifest.yaml"
```

Create the accounts on the cluster with `kubectl`:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_sa_manifest.yaml" \
--namespace "${NAMESPACE}"
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/consul \
  --name ${APP_INSTANCE_NAME} \
  $( [[ -n "${NAMESPACE}" ]] && printf '%s=%s' '--namespace' ${NAMESPACE} ) \
  --set global.image=${IMAGE_CONSUL} \
  --set server.prometheus_exporter.image=${IMAGE_CONSUL_EXPOTER} \
  --set server.prometheus_to_sd.image=${IMAGE_METRICS_EXPORTER} \
  --set global.domain=${CONSUL_DOMAIN} \
  --set global.datacenter=${CONSUL_DATACENTER} \
  --set server.ServiceAccount=${CONSUL_SERVER_SERVICE_ACCOUNT} \
  --set client.ServiceAccount=${CONSUL_CLIENT_SERVICE_ACCOUNT} \
  $( [[ -n "${SERVER_STORAGE}" ]] && echo "--set server.storage=${SERVER_STORAGE}" ) \
  --set global.gossipEncryption.CreateSecretWithKey=${CONSUL_GOSSIP_KEY:-null} \
  --set server.prometheus_exporter.enabled=${PROMETHEUS_EXPORTER:-false} \
  $( [[ -n "${REPLICAS}" ]] && echo "--set server.replicas=${REPLICAS}" ) \
  $( [[ -n "${SERVER_RESOURCES_LIMITS_CPU}" ]] && echo "--set server.resources.limits.cpu=${SERVER_RESOURCES_LIMITS_CPU}" ) \
  $( [[ -n "${SERVER_RESOURCES_LIMITS_MEMORY}" ]] && echo "--set server.resources.limits.memory=${SERVER_RESOURCES_LIMITS_MEMORY}" ) \
  $( [[ -n "${SERVER_RESOURCES_REQUESTS_CPU}" ]] && echo "--set server.resources.requests.cpu=${SERVER_RESOURCES_REQUESTS_CPU}" ) \
  $( [[ -n "${SERVER_RESOURCES_REQUESTS_MEMORY}" ]] && echo "--set server.resources.requests.memory=${SERVER_RESOURCES_REQUESTS_MEMORY}" ) \
  $( [[ -n "${CLIENT_RESOURCES_LIMITS_CPU}" ]] && echo "--set client.resources.limits.cpu=${CLIENT_RESOURCES_LIMITS_CPU}" ) \
  $( [[ -n "${CLIENT_RESOURCES_LIMITS_MEMORY}" ]] && echo "--set client.resources.limits.memory=${CLIENT_RESOURCES_LIMITS_MEMORY}" ) \
  $( [[ -n "${CLIENT_RESOURCES_REQUESTS_CPU}" ]] && echo "--set client.resources.requests.cpu=${CLIENT_RESOURCES_REQUESTS_CPU}" ) \
  $( [[ -n "${CLIENT_RESOURCES_REQUESTS_MEMORY}" ]] && echo "--set client.resources.requests.memory=${CLIENT_RESOURCES_REQUESTS_MEMORY}" ) \
  > ${APP_INSTANCE_NAME}_manifest.yaml
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

### Access Consul (internally)

You can connect to Consul without exposing it to public access, using the
`consul` command line interface.

#### Connect to Consul via Pod

To do this, please identify Consul's Pod using the following command:

```shell
kubectl get pods -o wide -l app.kubernetes.io/name=${APP_INSTANCE_NAME},app.kubernetes.io/component=consul-client --namespace "${NAMESPACE}"
```

Now you can access Consul tool. As example get consul version:

```shell
kubectl exec -it <pod name> --namespace "${NAMESPACE}" -- consul version
```

### Access Consul client directly in cluster

By default Consul client run on every Kubernetes node in cluster.
To access Consul client port you can connect directly to hostIP:8500

Example of pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: consul-client-example
spec:
  containers:
    - name: consul-example
      image: alpine
      env:
        - name: HOST_IP
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
      command:
        - "/bin/sh"
        - "-ec"
        - |
            export CONSUL_HTTP_ADDR="${HOST_IP}:8500"
            echo ${CONSUL_HTTP_ADDR}
            apk add curl
            curl -v ${CONSUL_HTTP_ADDR}
  restartPolicy: Never
```

### Access Consul UI (externally)

By default, the application does not have an external IP. To create an external IP address, run the following command:

> **NOTE:** This command exposes Consul externally without any authentication
> and encryption enabled. It is not recommended to use such configuration in
> production environment.

```shell
kubectl patch svc "${APP_INSTANCE_NAME}-consul-ui" \
  --namespace "${NAMESPACE}" \
  --patch '{"spec": {"type": "LoadBalancer"}}'
```


### Access Consul UI service (locally)
Consul UI will be available at [http://localhost:8500/](http://localhost:8500/)

```shell
kubectl port-forward svc/${APP_INSTANCE_NAME}-consul-ui --namespace ${NAMESPACE} 8500:80
```


# Scaling

## Scaling the cluster up

By default, the Consul Server application is deployed using 3 replicas.

To change the number of replicas:
1. Backup your data following [instructions](#backup-consul-data-to-your-local-computer)
2. Uninstall Consul Application following [instructions](#uninstall-the-application)
3. Delete PersistentVolumes volumes following [instructions](#delete-the-persistent-volumes-of-your-installation#)
4. Reuse installation instructions with new number of replicas.
5. Restore data following [instructions](#restore-consul-data-on-running-Consul)

> **NOTE:** Scaling via `kubectl scale` is not supported.

# Backup and Restore

The following steps are based on the [Consul documentation](https://www.consul.io/api/snapshot.html).

## Backup Consul data to your local environment

The first step you need to enable local access to Consul UI:

```shell
export APP_INSTANCE_NAME=consul-1
kubectl port-forward svc/${APP_INSTANCE_NAME}-consul-ui --namespace ${NAMESPACE} 8500:80
```

When port-forwarding is be ready you can run HTTP request to Consul API to create a snapshot:

```shell
curl http://127.0.0.1:8500/v1/snapshot -o snapshot.tgz
```

## Restore Consul data on a running cluster

Prepare port-forwarding as the same in [backup step](#backup-consul-data-to-your-local-computer)
Run commmand to push snapshot to Consul server:

```shell
curl --request PUT --data-binary @snapshot.tgz http://127.0.0.1:8500/v1/snapshot
```

# Upgrading the app

Before upgrading, we recommend that you prepare a backup of your Consul database,
using the [backup step](#backup-consul-data-to-your-local-computer).
For additional information about upgrades, see the [Consul documentation](https://www.consul.io/api/snapshot.html).

The Consul StatefulSet is configured to roll out updates automatically. Start the update by patching
the StatefulSet with a new image reference:

```shell
kubectl set image statefulset ${APP_INSTANCE_NAME}-consul-server --namespace ${NAMESPACE} \
  "consul=[NEW_IMAGE_REFERENCE]"
```

Where `[NEW_IMAGE_REFERENCE]` is the reference to new Docker image that you want to use.

To check the status of Pods in the StatefulSet, and the progress of
the new image, run the following command:

```shell
kubectl get pods --selector app.kubernetes.io/name=${APP_INSTANCE_NAME} \
  --namespace ${NAMESPACE}
```

# Uninstall the Application

## Using the Google Cloud Platform Console

1. In the GCP Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of applications, click **Consul**.

1. On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=consul-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend to use a kubectl version that is the same as the version of your cluster.
Using the same versions of kubectl and the cluster helps avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace ${NAMESPACE}
```

Otherwise, delete the resources using types and a label:

```shell
kubectl delete application \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

### Delete the persistent volumes of your installation

By design, the removal of StatefulSets in Kubernetes does not remove
PersistentVolumeClaims that were attached to their Pods. This prevents your
installations from accidentally deleting stateful data.

To remove the PersistentVolumeClaims with their attached persistent disks, run
the following `kubectl` commands:

```shell
# specify the variables values matching your installation:
export APP_INSTANCE_NAME=consul-1
export NAMESPACE=default

kubectl delete persistentvolumeclaims \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

### Delete the GKE cluster

Optionally, if you don't need the deployed application or the GKE cluster,
delete the cluster using this command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```
