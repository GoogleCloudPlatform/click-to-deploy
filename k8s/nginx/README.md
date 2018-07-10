# Overview
NGINX is open source software for web serving, reverse proxying, caching, load balancing, and media streaming. NGINX can also function as a proxy server for email (IMAP, POP3, and SMTP) and a reverse proxy and load balancer for HTTP, TCP, and UDP servers.

If you would like to learn more about NGINX, please, visit [NGINX website](https://www.nginx.com/).

## About Google Click to Deploy K8s Solutions

Popular open source software stacks on Kubernetes packaged by Google and made available in Google Cloud Marketplace.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this NGINX app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/nginx1).

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
export CLUSTER=marketplace-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to talk to the new cluster.

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo.

```shell
gcloud source repos clone google-click-to-deploy --project=k8s-marketplace-eap
gcloud source repos clone google-marketplace-k8s-app-tools --project=k8s-marketplace-eap
```

#### Install the Application resource definition

Do a one-time setup for your cluster to understand Application resources.

To do that, navigate to `k8s/vendor` subdirectory of the repository and run the following command:

```shell
kubectl apply -f google-marketplace-k8s-app-tools/crd/app-crd.yaml
```

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `nginx` directory.

```shell
cd google-click-to-deploy/k8s/nginx
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export APP_INSTANCE_NAME=nginx-1
export NAMESPACE=default
```

Configure the container images.

```shell
export IMAGE_NGINX="gcr.io/k8s-marketplace-eap/google/nginx1:1.15"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
digest=`docker pull $IMAGE_NGINX | sed -n -e 's/Digest: //p'`;
export $i="$repo@$digest";
env | grep $i;
```

#### Expand the manifest template

Use `envsubst` to expand the template. It is recommended that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_NGINX $REPLICAS' \
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

# Basic Usage

You can learn IP addresses of your NGINX solution either thru command line or thru GCP User Interface.

If you would like to learn IP addresses of the NGINX solution via GCP User Interface, please, do the following:
- navigate to Kubernetes Engine -> Services section
- identify NGINX solution using its name (e.g. nginx-1-nginx-svc)
- read the IP addresses (for port 80 and 443) from the "Endpoints" column.

If you are using CLI then run the following command:

```shell
kubectl get svc -l app.kubernetes.io/name=$APP_INSTANCE_NAME
```

This command will display internal and external IP address of your NGINX service.

# Scaling

By default, NGINX K8s application is deployed using 3 replicas. You can manually scale it up or down to deploy NGINX solution with desired number of replicas using the following command.

```shell
kubectl scale statefulsets "$APP_INSTANCE_NAME-nginx" --namespace "$NAMESPACE" --replicas=<new-replicas>
```

where <new_replicas> defines the number of replicas.

# Backup and Restore

TODO by rafalbiegacz@

# Update

This procedure assumes that you have a new image for NGINX container published and being available to your Kubernetes cluster. The new image is available at <url-pointing-to-new-image>.

Start with modification of the image used for pod temaplate within NGINX StatefulSet:

```shell
kubectl set image statefulset "$APP_INSTANCE_NAME-nginx" \
  nginx=<url-pointing-to-new-image>
```

where `<url-pointing-to-new-image>` is the new image.

To check the status of Pods in the StatefulSet and the progress of deployment of new image run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME
```

To check the current image used by pods within `NGINX` K8s application, you can run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' | sort
```

# Deletion

You can uninstall/delete NGINX application either using Google Cloud Console or using K8s Apps tools.

* Navigate to the `nginx` directory.

```shell
cd google-click-to-deploy/k8s/nginx
```
* Run the uninstall command

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

Optionally, if you don't need both the deployed application and GKE cluster used for deployment then you can delete the whole GKE cluster using this command:

```shell
gcloud container clusters delete "$CLUSTER" --zone "$ZONE"
```
