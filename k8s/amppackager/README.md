# Overview

AMP Packager is a tool to [improve AMP URLs][] by
[serving AMP using Signed Exchanges](https://amp.dev/documentation/guides-and-tutorials/optimize-and-measure/signed-exchange/).
By running it in a proper configuration, web publishers enable origin URLs to
appear in AMP search results.

The AMP Packager works by creating [Signed HTTP
Exchanges (SXGs)](https://wicg.github.io/webpackage/draft-yasskin-httpbis-origin-signed-exchanges-impl.html)
containing AMP documents, signed with a certificate associated with the origin,
with a maximum lifetime of 7 days. The [Google AMP
Cache](https://amp.dev/documentation/guides-and-tutorials/learn/amp-caches-and-cors/how_amp_pages_are_cached/) will fetch,
cache, and serve them, similar to what it does for normal AMP HTML documents.
When a user loads such an SXG, Chrome validates the signature and then displays
the certificate's domain in the URL bar instead of `google.com`, and treats the
web page as though it were on that domain.

The packager is an HTTP server that sits behind a frontend server; it fetches
and signs AMP documents as requested by the AMP Cache.

As an alternative to running the packager, you can sign up for one of the SXG [service providers](https://github.com/ampproject/amppackager/wiki/Service-Providers).

To learn more about AMP Packager, see the [AMP Packager Github Site](https://github.com/ampproject/amppackager/wiki/Service-Providers).

[improve AMP URLs]: https://blog.amp.dev/2018/11/13/developer-preview-of-better-amp-urls-in-google-search/

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

## Architecture

![Architecture diagram](resources/amppackager-k8s-app-architecture.png)

This application uses 2 replicas of the AMP Packager with a load balancer
service in front that routes requests to the instances. The number of replicas
is configurable.  All AMP Packager Pods are associated with an NFS Server as 
their PersistentVolume which is created as a standard persistent disk defined by
Google Kubernetes Engine.

This application exposes one endpoint: HTTPS on (configurable) port 6000.

This application requires a Signed Exchange Certificate in order to function.
The application, through its ACME Configuration, automatically requests and
retrieves this certificate from the Certificate Authority. The application also
periodically (approximately every 90 days) requests automatic renewal of the
certificate.

If you want to use this application in a production environment, you must:

*   Configure it to use your [DigiCert ACME account][] to obtain your
certificate.

[DigiCert ACME Account]:https://docs.digicert.com/manage-certificates/certificate-profile-options/get-your-signed-http-exchange-certificate/.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this AMP Packager app to a Google
Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/amppackager).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to complete the following steps.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/amppackager)

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your
environment by default.

-   [gcloud](https://cloud.google.com/sdk/gcloud/)
-   [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
-   [docker](https://docs.docker.com/install/)
-   [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
-   [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=amppackager-cluster
export ZONE=us-west1-a
export NUM_NODES=10 # The min value of NUM_NODES should be number of REPLICAS + 1. A larger number is acceptable.
gcloud container clusters create "$CLUSTER" --zone "$ZONE" --num-nodes="$NUM_NODES" --enable-ip-alias --metadata disable-legacy-endpoints=true
```

Configure `kubectl` to connect to the new cluster.

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo.

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following
command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `amppackager` directory:

```shell
cd click-to-deploy/k8s/amppackager
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app:

```shell
export APP_INSTANCE_NAME=amppackager-1
export NAMESPACE=default
export REPLICAS=2
```

Set up the image tag:

It is advised to use stable image reference which you can find on
[Marketplace Container Registry](https://marketplace.gcr.io/google/amppackager).
Example:

```shell
export TAG="1.0.2-20201016-235926"
```

Alternatively you can use short tag which points to the latest image for selected version.
> Warning: this tag is not stable and referenced image might change over time.

```shell
export TAG="1.0"
```

Configure the container images:

```shell
export IMAGE_AMPPACKAGER="marketplace.gcr.io/google/amppackager"
export IMAGE_AMPPACKAGER_INIT="marketplace.gcr.io/google/amppackager/init"
```

Set the storage class for the persistent volume of AMP Packager. 

Set the StorageClass name. You can select your existing StorageClass name for the persistent disk of the AMP Packager.
Set the persistent disk's size. The default disk size is "10Gi".

```shell
export STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export PERSISTENT_DISK_SIZE="10Gi"
```

#### Create a namespace in your Kubernetes cluster

If you use a different namespace than `default`, run the command below to create
a new namespace:

```shell
kubectl create namespace "$NAMESPACE"
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template chart/amppackager \
  --name "$APP_INSTANCE_NAME" \
  --namespace "$NAMESPACE" \
  --set replicaCount="$REPLICAS" \
  --set image.repo="$IMAGE_AMPPACKAGER" \
  --set image.tag="$TAG" \
  --set init.repo="$IMAGE_AMPPACKAGER_INIT" \
  --set init.tag"$TAG" \
  --set packager.persistence.storageClass="$STORAGE_CLASS" \
  --set packager.persistence.size="$PERSISTENT_DISK_SIZE" \
  --set packager.domain="$AMPPACKAGER_DOMAIN" \
  --set packager.country="$AMPPACKAGER_COUNTRY" \
  --set packager.locality="$AMPPACKAGER_LOCALITY" \
  --set packager.organization="$AMPPACKAGER_ORGANIZATION" \
  --set acme.emailAddress="$ACME_EMAIL_ADDRESS" \
  --set acme.directoryUrl="$ACME_DIRECTORY_URL" \
  --set service.loadBalancerSourceRanges="$AMPPACKAGER_LOAD_BALANCER_RANGE" \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the GCP Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view your app, open the URL in your browser.

# Using the app

You can get the IP addresses for your AMP Packager solution either from the
command line, or from the Google Cloud Platform Console.

In the GCP Console, do the following:

1.  Open the
    [Kubernetes Engine Services](https://console.cloud.google.com/kubernetes/discovery)
    page.
1.  Identify the AMP Packager solution using its name (typically `amppackager-service`,
    unless you decide to name your instance some other name).
1.  From the Endpoints column, note the IP addresses for ports 6000.

If you are using the command line, run the following command:

```shell
kubectl get svc -l app.kubernetes.io/name=$APP_INSTANCE_NAME --namespace "$NAMESPACE"
```

This command shows the internal and external IP address of your AMP Packager
service.

You can follow [AMP Packager Productionizing][Production] for further steps.

[Production]:https://github.com/ampproject/amppackager#productionizing

# Scaling

By default, the AMP Packager application is deployed using 2 replicas. You can
manually scale it up or down using the following command:

```shell
kubectl scale statefulsets "$APP_INSTANCE_NAME-amppackager" \
  --namespace "$NAMESPACE" \
  --replicas=[NEW_REPLICAS]
```

where `[NEW_REPLICAS]` is the new number of replicas.

# Uninstalling the app

You can delete the AMP Packager application using the Google Cloud Platform
Console, or using the command line.

## Using the Google Cloud Platform Console

1.  In the GCP Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1.  From the list of applications, click **AMP Packager**.

1.  On the Application Details page, click **Delete**.

## Using the command line

1.  Navigate to the `amppackager` directory.

    ```shell
    cd click-to-deploy/k8s/amppackager
    ```

1.  Run the `kubectl delete` command:

    ```shell
    kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
    ```

Optionally, if you don't need the deployed application or the Kubernetes Engine
cluster, delete the cluster using this command:

```shell
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```
