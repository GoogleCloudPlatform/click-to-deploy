# Overview

Trillian makes it easy to build cryptographically verifiable solutions enabling
developers to minimize the trust users must place in the solutions they build.
This is accomplished by applying the concept of cryptographic transparency to
the storage and distribution of data.

When properly implemented this moves solutions from a model of ”trust us” to a
model of ”you can verify we do what we say”.

Architecturally this is accomplished by providing a relatively simple
abstraction that can be used to store a ledger of values or a set of keys and
associated values and have the data be added to an append only ordered list
known as a [merkle tree](https://en.wikipedia.org/wiki/Merkle_tree). This
abstraction takes care of the management of the cryptographic aspects necessary
to deliver on this transparency principal.

Behind this abstraction is a database abstraction that enables storing these
values into Cloud Spanner, My SQL and other databases.

This approach allows solutions to scale to 10s of billions of entries and over
2k transactions a second without struggling complex engineering tasks.

This platform is the basis of
[Certificate Transparency](https://en.wikipedia.org/wiki/Certificate_Transparency),
[Key Transparency](https://security.googleblog.com/2017/01/security-through-transparency.html),
[Verifiable Data Audit](https://www.wired.com/2017/03/google-deepminds-untrendy-blockchain-play-make-actually-useful/)
and other solutions.

[Learn more](https://github.com/trillian/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

## Design

![Architecture diagram](https://github.com/google/certificate-transparency-go/blob/c0b58057e5831c0fe4c19a193c273b50704fd82a/trillian/docs/images/DeploymentFull.png)

*   **Personality** - translates between Trillian's API and the API you want to
    expose to users. This is not included in the deployment - you must implement
    and add this yourself.

*   **Log Server** - exposes a gRPC API for interacting with the ledgers
    (referred to as "logs" by Trillian).

*   **Log Signer** - adds new queued entries to logs. This is a background
    process.

*   **Etcd Cluster** - used to handle rate-limiting/quota and master election.

## Configuration

*   The number of Trillian log server and signer replicas is specified by the
    user before installation, and can later be scaled as required. Most
    configuration options are stored in a ConfigMap.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install Trillian to a Google Kubernetes
Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/trillian).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment: -
[gcloud](https://cloud.google.com/sdk/gcloud/) -
[kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) -
[docker](https://docs.docker.com/install/) -
[git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
[make](https://www.gnu.org/software/make/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=trillian-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" \
  --zone "$ZONE" --machine-type=n1-standard-2 \
  --enable-autoscaling --min-nodes=3 --max-nodes=10
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

To set up your cluster to understand Application resources, run the following
command:

```shell
make -C click-to-deploy/k8s/trillian crd/install
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

#### Make sure you are a Cluster Admin

Installing Trillian creates a custom cluster role, in order to provide necessary
privileges to Etcd. You must be a Cluster Admin in order for the installer to do
this on your behalf. To assign the Cluster Admin role to your user account, run
the following command:

```shell
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)
```

Next, choose the instance name, namespace and Trillian release tag to use, then
run the installer. If you are not using the "default" namespace, you may need to
[create the namespace](https://kubernetes.io/docs/tasks/administer-cluster/namespaces/#creating-a-new-namespace)
first.

```shell
export APP_INSTANCE_NAME=trillian-1
export NAMESPACE=default
export TAG=v1.2.1

make -C click-to-deploy/k8s/trillian app/install
```

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view your app, open the URL in your browser.

## Forward Trillian gRPC port in local environment

Use local port forwarding to access Trillian's gRPC API from your machine. In a
terminal, run the following command:

```shell
kubectl port-forward --namespace ${NAMESPACE} service/${APP_INSTANCE_NAME}-logserver-service 8090
```

You can then access the Trillian API at `localhost:8090`.

# Scaling the Trillian app

## Scaling the servers

By default, the Trillian app is deployed using 4 server replicas. To change the
number of replicas, use the following commands. Change `$LOGSERVER_REPLICAS` to
the number of replicas you require. Increasing the number will increase capacity
for serving requests.

```shell
LOGSERVER_REPLICAS=4

kubectl scale "deployments/${APP_INSTANCE_NAME}-logserver-deployment" \
  --namespace "${NAMESPACE}" --replicas ${LOGSERVER_REPLICAS}
```

## Scaling the signers

By default, the Trillian app is deployed using 2 signer replicas. To change the
number of replicas, use the following commands. Change `$LOGSIGNER_REPLICAS` to
the number of replicas you require. Increasing the number will increase the
number of logs that can be signed in parallel.

```shell
LOGSIGNER_REPLICAS=2

kubectl scale "deployments/${APP_INSTANCE_NAME}-logsigner-deployment" \
  --namespace "$NAMESPACE" --replicas $LOGSIGNER_REPLICAS
```

## Scaling etcd

Shrinking an etcd cluster is not recommended, but increasing the cluster size is
safe. This can be achieved by the following command. Change `$ETCD_CLUSTER_SIZE`
to the desired cluster size.

```shell
ECTD_CLUSTER_SIZE=5

kubectl patch EtcdCluster "${APP_INSTANCE_NAME}-etcd-cluster" --type "merge" \
  --patch "{\"spec\":{\"size\":$ETCD_CLUSTER_SIZE}}"
```

# Backup and Restore

Backup and restore is not supported for Trillian. Due to the append-only nature
of logs, backup and restore is a dangerous operation because it could result in
entries being removed from a log.

# Updating the app

To update the Trillian app, select a new version from the
[GitHub releases page](https://github.com/google/trillian/releases) and use it
as the value of `TAG` below. Then re-install the Trillian app. For example, to
update to version "v1.2.1":

```shell
export APP_INSTANCE_NAME=trillian-1
export NAMESPACE=default
export TAG=v1.2.1

make -C click-to-deploy/k8s/trillian app/install
```

# Uninstall the Application

## Using the Google Cloud Platform Console

1.  In the GCP Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1.  From the list of applications, click **Trillian**.

1.  On the Application Details page, click **Delete**.

1.  To cleanup the Etcd cluster, run the following command:

    ```shell
    export APP_INSTANCE_NAME=trillian-1
    export NAMESPACE=default

    kubectl delete EtcdCluster "${APP_INSTANCE_NAME}-etcd-cluster" --namespace "$NAMESPACE"
    ```

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=trillian-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend to use a kubectl version that is the same as the
> version of your cluster. Using the same versions of kubectl and the cluster
> helps avoid unforeseen issues.

Delete all resources matching the name you used during installation:

```shell
kubectl delete application,deployment,service \
  --namespace "${NAMESPACE}" \
  --selector "app.kubernetes.io/name=${APP_INSTANCE_NAME}"
```

### Delete the MySQL persistent volume

By design, the removal of the Trillian app does not remove the
PersistentVolumeClaim used by the MySQL Deployment. This prevents your
installations from accidentally deleting the database.

To remove the PersistentVolumeClaim with its attached persistent disk, run the
following `kubectl` command:

```shell
kubectl delete persistentvolumeclaims \
  --namespace "${NAMESPACE}" \
  --selector "app.kubernetes.io/name=${APP_INSTANCE_NAME}"
```

### Delete the GKE cluster

Optionally, if you don't need the deployed application or the GKE cluster,
delete the cluster using this command:

```
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```
