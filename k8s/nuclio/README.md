# Overview

Nuclio is a new "serverless" project, derived from Iguazio's elastic data
life-cycle management service for high-performance events and data processing.

Nuclio allows to write a source code of functions defined in a platform-specific
convention (including the triggers configuration or stateful data definition).
Nuclio manages the conversion of the source code into container images (stored
in a configurable Docker registry - for this application Google Container
Registry) and deploying their workloads to a Kubernetes cluster.

For more information on Nuclio, see the [Nuclio official website](https://www.nuclio.io/).

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

## Architecture

![Architecture diagram](resources/nuclio-k8s-app-architecture.png)

The application offers Nuclio CRDs and deployments of Nuclio controller and dashboard on a Kubernetes cluster.

Installation requires access to a Docker registry to build and deploy Nuclio applications.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Nuclio app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/nuclio).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your
environment by default.

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create Service Account to access GCP Registry

To provide access to GCP Registry, you must create service account for Nuclio
application.

1. Open [GCP Console](https://console.cloud.google.com/) in your browser.
1. Open **IAM & admin** in the navigation menu from the sidebar and then click **Service accounts**.
1. Press **+ CREATE SERVICE ACCOUNT**
    1. Provide the name for a new service account.
    Before saving a new account, please take a note of the generated "Service
    account ID", similar to `[SA_NAME]@[PROJECT_ID].iam.gserviceaccount.com`. It
    will be needed on next steps.
    1. Click **Done** to proceed to the next step.
1. Click **Continue** to skip "Grant this service account access to project"
step without changes.
1. On "Grant users access to this service account" step you must create and
   download a secret key.
1. Click **CREATE KEY** and choose to use JSON key type.
    1. Click **CREATE**.
    1. JSON Key will be automatically downloaded. Store key file in secure place.
    It will be required for further configuration steps.

Setup permissions for the created service account:

1. Open **Storage** in the navigation menu.
1. Find a bucket which is used as the Docker registry similar to
`artifacts.[PROJECT_ID].appspot.com`. Open by clicking on it.
1. Switch to the **Permissions** tab.
1. Click **Add members**.
    1. Add new member by Service account ID which was noted at previous steps.
    1. Choose **Storage** -> **Storage Admin** to add new role for Service account.
    1. Click **SAVE** to save new role

To create a Kubernetes Secret resource, please follow the [instructions](#create-secret-resource-for-gcp-docker-registry)

#### Create a Google Kubernetes Engine (GKE) cluster

Create a new cluster from the command line:

```shell
export CLUSTER=nuclio-cluster
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

Navigate to the `nuclio` directory:

```shell
cd click-to-deploy/k8s/nuclio
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=nuclio-1
export NAMESPACE=default
```

Configure the container image:

```shell
export TAG=1.1
export IMAGE_CONTROLLER="marketplace.gcr.io/google/nuclio"
export IMAGE_DASHBOARD="marketplace.gcr.io/google/nuclio/dashboard"
```

In case you are using the GCR Docker registry, you should define push/pull URL, which is different from login URL.

For use Docker registry from current project:

```shell
export PUSH_PULL_URL="gcr.io/$(gcloud config get-value project)/${APP_INSTANCE_NAME}-images"
```

Optionally you can define another registry secret name.
By default it is ${APP_INSTANCE_NAME}-registry-credentials

```shell
export REGISTRY_SECRET="docker-credentials"
```

Optionally you can set the number of replicas for Nuclio dashboard:
Default and recommended value is 1.

```shell
export DASHBOARD_REPLICAS=1
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Create Secret resource for GCP Docker registry

This step will require key which you can create following [instructions](#create-service-account-to-access-gcp-registry)

If you use a different namespace than the `default`, please create it following the [instructions](#create-namespace-in-your-kubernetes-cluster)

To create Secret resource which contains credentials for the GCP Docker registry, modify and run the following command.

```shell
export KEY_JSON=[PATH_TO_KEY]
kubectl --namespace "${NAMESPACE}" create secret docker-registry ${APP_INSTANCE_NAME}-registry-credentials \
        --docker-server=gcr.io \
        --docker-username=_json_key \
        --docker-password="$(cat ${KEY_JSON})" \
        --docker-email=email@example.com
```
where `PATH_TO_KEY` is path to key created in previous step.

In case you decide to use private Docker registry you can create this Secret using the [official Kubernetes instructions](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).

##### Create dedicated Service Accounts

Define the environment variables:

```shell
export DASHBOARD_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-nuclio-dashboard"
export CONTROLLER_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-nuclio-controller"
export CRD_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-nuclio-crd-creator-job"
```

Expand the manifest to create Service Accounts:

```shell
cat resources/service-accounts.yaml \
  | envsubst '${APP_INSTANCE_NAME} \
              ${NAMESPACE} \
              ${DASHBOARD_SERVICE_ACCOUNT} \
              ${CONTROLLER_SERVICE_ACCOUNT} \
              ${CRD_SERVICE_ACCOUNT}' \
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
helm template chart/nuclio \
  --name ${APP_INSTANCE_NAME} \
  --namespace=${NAMESPACE}" \
  --set controller.image.repository=${IMAGE_CONTROLLER} \
  --set controller.image.tag=${TAG} \
  --set dashboard.image.repository=${IMAGE_DASHBOARD} \
  --set dashboard.image.tag=${TAG} \
  --set deployerHelm.image="gcr.io/cloud-marketplace-tools/k8s/deployer_helm:0.8.0" \
  $( [[ -n "${PUSH_PULL_URL}" ]] && echo "--set registry.pushPullUrl=${PUSH_PULL_URL}" ) \
  $( [[ -n "${REGISTRY_SECRET}" ]] && echo "--set registry.registry.secretName=${REGISTRY_SECRET}" ) \
  $( [[ -n "${DASHBOARD_REPLICAS}" ]] && echo "--set dashboard.replicas=${DASHBOARD_REPLICAS}" ) \
  --set dashboard.serviceAccountName=${DASHBOARD_SERVICE_ACCOUNT} \
  --set controller.serviceAccountName=${CONTROLLER_SERVICE_ACCOUNT} \
  --set CDRJobServiceAccount=${CRD_SERVICE_ACCOUNT} \
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

### Access Nuclio dashboard service (locally)
Nuclio dashboard will be available at [http://localhost:8070/](http://localhost:8070/)

```shell
kubectl --namespace "${NAMESPACE}" port-forward service/${APP_INSTANCE_NAME}-dashboard 8070:8070
```

# Scaling up or down

### Nuclio controller

Scaling is not supported for Nuclio controller.

### Nuclio dashboard

To change the number of dashboard replicas, use the following command:

```shell
kubectl scale deployment "${APP_INSTANCE_NAME}-dashboard" \
  --namespace "${NAMESPACE}" --replicas=<new-replicas>
```

# Backup and Restore

## Backup Nuclio configuration data to your local environment

Backup Nuclio resources using the following command:

```shell
export NAMESPACE=default
kubectl --namespace "${NAMESPACE}" get crd \
   nucliofunctionevents.nuclio.io \
   nucliofunctions.nuclio.io \
   nuclioprojects.nuclio.io \
   --output=yaml > backup_file.yaml
```

## Restore Nuclio configuration

```shell
kubectl --namespace "${NAMESPACE}" apply -f backup_file.yaml
```

# Upgrading the app

The Nuclio Deployments is configured to roll out updates automatically. Start the update by patching the Deployment with a new image reference:

```shell
kubectl set image deployment ${APP_INSTANCE_NAME}-dashboard --namespace ${NAMESPACE} \
  "nuclio=[NEW_DASHBOARD_IMAGE_REFERENCE]"
kubectl set image deployment ${APP_INSTANCE_NAME}-controller --namespace ${NAMESPACE} \
  "nuclio=[NEW_CONTROLLER_IMAGE_REFERENCE]"
```

Where `[NEW_DASHBOARD_IMAGE_REFERENCE]` and `[NEW_CONTROLLER_IMAGE_REFERENCE]` are the Docker image references of the new images that you want to use.

To check the status of Pods in the StatefulSet, and the progress of
the new image, run the following command:

```shell
kubectl get pods --selector app.kubernetes.io/name=${APP_INSTANCE_NAME} \
  --namespace ${NAMESPACE}
```

# Uninstall the Application

## Using the Google Cloud Platform Console

1. In the GCP Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).
1. From the list of applications, click **Nuclio**.

1. On the Application Details page, click **Delete**.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=nuclio-1
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

> **NOTE:** It will delete only the nuclio application. All nuclio managed resources will be available.

### Delete the GKE cluster

Optionally, if you don't need the deployed application or the GKE cluster,
delete the cluster using this command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```

