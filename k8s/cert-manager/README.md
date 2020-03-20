# Overview

Cert Manager provides native k8s automation for creation and manages TLS
certificates.

Solution supports functionality for making self signed certificates, using your
own CA, and using external services like Let’s Encrypt, HashiCorp Vault, and
Venafi.

Also the solution takes care of validity, up to date, and attempts to renew
certificates before they expire.

For more information, visit the
[Cert Manager official website](https://cert-manager.io/docs/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

![Architecture diagram](resources/cert-manager-k8s-app-architecture.png)

The app offers Cert Manager custom resource definitions (CRDs), WebHooks and
deployments of Cert Manager on a Kubernetes cluster.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Cert Manager app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/cert-manager).

## Command-line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, then `gcloud`, `kubectl`, Docker, and Git are installed in
your environment by default.

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine (GKE) cluster

Create a new cluster from the command line:

```shell
export CLUSTER=cert-manager-cluster
export ZONE=us-west1-a

gcloud container clusters create "${CLUSTER}" --zone "${ZONE}"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}"
```

#### Clone this repo

Clone this repo and its associated tools repo:

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

### Install the app

Navigate to the `cert-manager` directory:

```shell
cd click-to-deploy/k8s/cert-manager
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=cert-manager-1
export NAMESPACE=default
```

Enable Stackdriver Metrics Exporter:

> **NOTE:** Your GCP project must have Stackdriver enabled. If you are using a
> non-GCP cluster, you cannot export metrics to Stackdriver.

By default, the application does not export metrics to Stackdriver. To enable
this option, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=true
```

Set up the image tag:

It is advised to use stable image reference which you can find on
[Marketplace Container Registry](https://marketplace.gcr.io/google/cert-manager).
Example:

```shell
export TAG="0.13.0-20200311-092536"
```

Alternatively you can use short tag which points to the latest image for selected version.
> Warning: this tag is not stable and referenced image might change over time.

```shell
export TAG="0.13"
```

Configure the container image:

```shell
export IMAGE_CONTROLLER="marketplace.gcr.io/google/cert-manager"
export IMAGE_METRICS_EXPORTER="marketplace.gcr.io/google/cert-manager/prometheus-to-sd:${TAG}"
```

By default 1 replica for each deployment, but optionally you can set the number
of replicas for Cert Manager controller, webhook and cainjector.

```shell
export CONTROLLER_REPLICAS=3
export WEBHOOK_REPLICAS=3
export CAINJECTOR_REPLICAS=3
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

##### Create dedicated Service Accounts

Define the environment variables:

```shell
export CONTROLLER_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-cert-manager-controller"
export WEBHOOK_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-cert-manager-webhook"
export CAINJECTOR_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-cert-manager-cainjector"
export CRD_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-crd-creator-job"
```

Expand the manifest to create Service Accounts:

```shell
cat resources/service-accounts.yaml \
  | envsubst '${APP_INSTANCE_NAME} \
              ${NAMESPACE} \
              ${CONTROLLER_SERVICE_ACCOUNT} \
              ${WEBHOOK_SERVICE_ACCOUNT} \
              ${CAINJECTOR_SERVICE_ACCOUNT} \
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
expanded manifest file for future updates to the app.

```shell
helm template chart/cert-manager \
  --name ${APP_INSTANCE_NAME} \
  --namespace ${NAMESPACE} \
  --set controller.image.repo=${IMAGE_CONTROLLER} \
  --set controller.image.tag=${TAG} \
  --set controller.serviceAccountName=${CONTROLLER_SERVICE_ACCOUNT} \
  --set controller.replicas=${CONTROLLER_REPLICAS:-1} \
  --set deployer.image="gcr.io/cloud-marketplace-tools/k8s/deployer_helm:0.8.0" \
  --set CDRJobServiceAccount=${CRD_SERVICE_ACCOUNT} \
  --set webhook.serviceAccountName=${WEBHOOK_SERVICE_ACCOUNT} \
  --set webhook.replicas=${WEBHOOK_REPLICAS:-1} \
  --set cainjector.serviceAccountName=${CAINJECTOR_SERVICE_ACCOUNT} \
  --set cainjector.replicas=${CAINJECTOR_REPLICAS:-1} \
  --set metrics.exporter.enabled=${METRICS_EXPORTER_ENABLED:-false} \
  > ${APP_INSTANCE_NAME}_manifest.yaml
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Cloud Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.


# Deploy an Issuer and Cert request for self-signed certificate

Run the following command to deploy an Issuer instance:

```shell
kubectl apply --namespace "${NAMESPACE}" -f - <<EOF
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: test-selfsigned
spec:
  selfSigned: {}
EOF
```

Run the following command for requesting a certificate:

```shell
kubectl apply --namespace "${NAMESPACE}" -f - <<EOF
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: selfsigned-cert
spec:
  dnsNames:
    - example.com
  secretName: selfsigned-cert-tls
  issuerRef:
    name: test-selfsigned
EOF
```

The created certificate will be available as Secret resource selfsigned-cert-tls.

Optionally, you can deploy the issuer and the certificate to another namespace.

You can find additional configuration options at the
[official Cert Manager documentation page](https://cert-manager.io/docs/usage/).

# Scaling up or down

To change the number of replicas of controller, use the following command, where `REPLICAS` is desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment "${APP_INSTANCE_NAME}-cert-manager" \
  --namespace "${NAMESPACE}" --replicas=$REPLICAS
```

To change the number of replicas of cainjector, use the following command, where `REPLICAS` is desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment "${APP_INSTANCE_NAME}-cert-manager-cainjector" \
  --namespace "${NAMESPACE}" --replicas=$REPLICAS
```

To change the number of replicas of webhook, use the following command, where `REPLICAS` is desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment "${APP_INSTANCE_NAME}-cert-manager-webhook" \
  --namespace "${NAMESPACE}" --replicas=$REPLICAS
```

# Back up and restore

## Back up Cert Manager configuration data to your local environment

To back up Cert Manager resources, use the following command:

```shell
kubectl get --all-namespaces --output=yaml \
issuer,clusterissuer,certificates,certificaterequests > backup_file.yaml
```

## Restore Cert Manager configuration data from your local environment

```shell
kubectl apply -f backup_file.yaml
```

# Upgrading the app

For update cert manager version please check [official documentation](https://cert-manager.io/docs/installation/upgrading/)
for version specific actions.

We recomend to make a backup before trying to update Cert Manager

# Uninstall the app

## Using the Google Cloud Console

1. In the Cloud Console, open [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1. From the list of apps, click **Cert Manager**.

1. On the Application Details page, click **Delete**.

## Using the command-line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=cert-manager-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend that you use a `kubectl` version that
is the same version as that of your cluster. Using the same versions
of `kubectl` and the cluster helps to avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace ${NAMESPACE}
```

Otherwise, delete the resources by using types and a label:

```shell
kubectl delete application \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

> **NOTE:** This will delete only the `cert-manager` app. All
`cert-manager`-managed resources will remain available.

### Delete the GKE cluster

Optionally, if you don't need the deployed app or the GKE cluster,
delete the cluster by using this command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```
