# Overview

NGINX is open source software for web serving, reverse proxying, caching, load balancing, and media streaming.
NGINX can also function as a proxy server for email (IMAP, POP3, and SMTP) and a reverse proxy and load balancer for HTTP, TCP, and UDP servers.

If you would like to learn more about NGINX, please, visit [NGINX website](https://www.nginx.com/).

This particular web server application uses NGINX for web serving and it was configured to serve only static content.
Each NGINX pod is associated with its own persistent volume created as standard persistent disk type defined by Google Kubernetes Engine.

This web server application is pre-configured with SSL certificate. Please, replace it (per instructions delivered) with your valid SSL certificate.

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this NGINX app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/nginx).

## Command line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

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

<!--
To do that, navigate to `k8s/vendor` subdirectory of the repository and run the following command:
-->

```shell
kubectl apply -f google-marketplace-k8s-app-tools/crd/*
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
export REPLICAS=3
```

Configure the container images.

```shell
TAG=1.15
export IMAGE_NGINX="gcr.io/k8s-marketplace-eap/google/nginx:${TAG}"
export IMAGE_NGINX_INIT="gcr.io/k8s-marketplace-eap/google/nginx/debian9:${TAG}"
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
for i in "IMAGE_NGINX IMAGE_NGINX_INIT"; do
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
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_NGINX $IMAGE_NGINX_INIT $REPLICAS' \
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

where `<new_replicas>` defines the new desired number.

# Backup and Restore

To perform backup & restore of the content of your NGINX web server you can use scripts proved for you in `google-click-to-deploy/k8s/nginx/scripts` folder.

## Backup 

To perform backup of the content of your NGINX web server run the following command:

```shell
export APP_INSTANCE_NAME=<the name of your application, e.g. nginx-1>
export NAMESPACE=default
cd google-click-to-deploy/k8s/nginx/scripts
./backup-webdata.sh
```
The web server content will be stored in `backup` folder.

## Restore
To perform restore of the content of your NGINX web server run the following commands

```shell
export APP_INSTANCE_NAME=<the name of your application, e.g. nginx-1>
export NAMESPACE=default
cd google-click-to-deploy/k8s/nginx/scripts
./upload-webdata.sh
```

# Re-configure certificate of your NGINX server

It's higly recommened that you use a valid certificate issued by an approved Certificate Authority for your NGINX server.

To update the certificate for NGINX server you need to have:
- certificate file (for example in X509 format)
- private key file (in the PEM format; if using a signed certificate - use bundled file with your domain certificate and the intermediate one)

To update the certificate for a running NGINX server do the following:
1. Save the certificate under `https1.cert` file in `google-click-to-deploy/k8s/nginx/scripts` folder.
1. Save the private key of your certificate under `https1.key` file in `google-click-to-deploy/k8s/nginx/scripts` folder.
1. Copy `google-click-to-deploy/k8s/nginx/scripts/nginx-update-cert.sh` to the folder where `https1.cert` and `https1.key` are stored.
1. Define APP_INSTANCE_NAME environment variable ```export APP_INSTANCE_NAME=<the name of your application, e.g. nginx-1>```
1. Define NAMESPACE environment variable ``` export NAMESPACE=default```
1. Run the update script: `./nginx-update-cert.sh`.

NOTE: Please, make sure to perform above-mentioned operations outside of directory
where you cloned `google-click-to-deploy` repository to avoid accidental commit on `https1.cert` and `https1.key` files.

NOTE: `google-click-to-deploy/k8s/nginx/scripts/nginx-create-key.sh` script can be helpful
if you would like to generate self-signed certificate.

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
