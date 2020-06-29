# Overview

GitLab is a DevOps tool for the entire software development and operations lifecycle.
It offers backlog and planning tools, source code management, built-in continuous integration pipelines
(CI/CD), packages and artifacts management, issue-tracking and monitoring tools.

For more information, visit the GitLab [official website](https://gitlab.com/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

![Architecture diagram](resources/gitlab-k8s-app-architecture.png)

A Kubernetes StatefulSet manages GitLab Enterprise Edition single-instance solution.

By default, GitLab is exposed externally using a LoadBalancer Service by three ports, as follows:

* `22` - for SSH connections
* `80` - for HTTP interface
* `443` - for HTTPS interface

A StatefulSet object is used to manage the GitLab workload,
using container based on [omnibus-gitlab](https://gitlab.com/gitlab-org/omnibus-gitlab/).
Thus you should have 1 replica as a part of a StatefulSet.

Additional workloads are available for a separate PostgreSQL and Redis single-instance solutions.
Both deployments are not exposed externally and you can connect internally via following ports:

* `6379` - for Redis Instance
* `5432` - for PostgreSQL Instance

GitLab instance can be customised by providing configurations via Configmap.
For more information, [check available configuration options](https://docs.gitlab.com/omnibus/settings/configuration.html).

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! To install this GitLab
app to a Google Kubernetes Engine cluster via Google Cloud
Marketplace, follow these
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/gitlab).

## Command-line instructions

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment:

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [openssl](https://www.openssl.org/)
- [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine (GKE) cluster

Create a new cluster from the command-line:

```shell
export CLUSTER=gitlab-cluster
export ZONE=us-west1-a

gcloud container clusters create "${CLUSTER}" --zone "${ZONE}"
```

Configure `kubectl` to connect to the new cluster:

```shell
gcloud container clusters get-credentials "${CLUSTER}" --zone "${ZONE}"
```

#### Clone this repo

Clone this repo, as well as its associated tools repo:

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes
components, such as Services, StatefulSets, and so on, that you can
manage as a group.

To set up your cluster to understand Application resources, run the
following command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. You can find the source code at
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the app

Navigate to the `gitlab` directory:

```shell
cd click-to-deploy/k8s/gitlab
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=gitlab-1
export NAMESPACE=default
```

Enable Cloud Monitoring:

> **NOTE:** Your Google Cloud Marketplace project must have
> Cloud Monitoring enabled. If you are using a non-Google Cloud
> cluster, you cannot export metrics to Cloud Monitoring.

By default, the application does not export metrics to Cloud
Monitoring. To enable this option, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=false
```

Set up the image tag:

It is advised to use a stable image reference, such as the one
in the
[Marketplace Container Registry](https://marketplace.gcr.io/google/gitlab).

Example:

```shell
export TAG="12.9.4-<BUILD_ID>"
```

Alternatively, you can use a short tag to point to the latest
image for your selected version.

> Warning: this tag is not stable, and the image that it references
> might change over time.

```shell
export TAG="12.9"
```

Configure the container images:

```shell
export IMAGE_REGISTRY="marketplace.gcr.io/google"

export IMAGE_GITLAB="${IMAGE_REGISTRY}/gitlab"
export IMAGE_REDIS="${IMAGE_REGISTRY}/gitlab/redis:${TAG}"
export IMAGE_REDIS_EXPORTER="${IMAGE_REGISTRY}/gitlab/redis-exporter:${TAG}"
export IMAGE_POSTGRESQL="${IMAGE_REGISTRY}/gitlab/postgresql:${TAG}"
export IMAGE_POSTGRESQL_EXPORTER="${IMAGE_REGISTRY}/gitlab/postgresql-exporter:${TAG}"
export IMAGE_DEPLOYER="${IMAGE_REGISTRY}/gitlab/deployer:${TAG}"
export IMAGE_METRICS_EXPORTER="${IMAGE_REGISTRY}/gitlab/prometheus-to-sd:${TAG}"
```

Set or generate the password for the GitLab services:

```shell
# Set alias for password generation
alias generate_pwd="cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1 | tr -d '\n'"

# Generate password for GitLab, Redis and PostgreSQL
export GITLAB_ROOT_PASSWORD="$(generate_pwd)"
export REDIS_ROOT_PASSWORD="$(generate_pwd)"
export POSTGRES_PASSWORD="$(generate_pwd)"
```

For the persistent disk provisioning of the GitLab StatefulSets,
you will need to:

 * Set the StorageClass name. Check your available options
 using the command below:
   * ```kubectl get storageclass```
   * Or check how to create a new StorageClass in [Kubernetes Documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#the-storageclass-resource)

```shell
export DEFAULT_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
```

#### Set GitLab domain name

Optional: set `DOMAIN_NAME` variable to configure GitLab instance URL.

```shell
export DOMAIN_NAME="gitlab.example.com"
```

Leave this variable empty if you want GitLab instance to be configured
with automatically provided external IP.

```shell
unset DOMAIN_NAME
```

#### GitLab SSL configuration

This Helm chart offers several possible SSL configurations which has different result
in combination with `DOMAIN_NAME`:

Example configurations:

* Dynamic external IP with SSL disabled:
  ```shell
  unset DOMAIN_NAME
  export SSL_CONFIGURATION="Default"
  ```

* Dynamic external IP with a self-signed certificate:
  ```shell
  unset DOMAIN_NAME
  export SSL_CONFIGURATION="Self-signed"
  ```

* Domain name with a Let's encrypt certificate:
  > Important: A valid domain name should be provided in this option.
  > Provided DNS should be resolvable, otherwise Let's Encrypt will not be able
  > to create a valid certificate and your deployment will fail.

  ```shell
  export DOMAIN_NAME="gitlab.example.com"
  export SSL_CONFIGURATION="Default"
  ```

#### Create TLS certificate for GitLab

> This step is optional and should be used only if `SSL_CONFIGURATION` set as `Self-signed`.

1.  If you already have a certificate that you want to use, copy your
    certificate and key pair to the `/tmp/tls.crt`, and `/tmp/tls.key` files,
    then skip to the next step.

    To create a new certificate, run the following command:

    ```shell
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /tmp/tls.key \
        -out /tmp/tls.crt \
        -subj "/CN=gitlab/O=gitlab"
    ```

2.  Set `TLS_CERTIFICATE_KEY` and `TLS_CERTIFICATE_CRT` variables:

    ```shell
    export TLS_CERTIFICATE_KEY="$(cat /tmp/tls.key | base64)"
    export TLS_CERTIFICATE_CRT="$(cat /tmp/tls.crt | base64)"
    ```


#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the
command below to create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Create the GitLab Service Account

To create the GitLab Service Account and ClusterRoleBinding:

```shell
export GITLAB_SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-serviceaccount"
kubectl create serviceaccount "${GITLAB_SERVICE_ACCOUNT}" --namespace "${NAMESPACE}"
kubectl create clusterrole "${GITLAB_SERVICE_ACCOUNT}-role" --verb=get,list,watch --resource=services,nodes,pods,namespaces
kubectl create clusterrolebinding "${GITLAB_SERVICE_ACCOUNT}-rule" --clusterrole="${GITLAB_SERVICE_ACCOUNT}-role" --serviceaccount="${NAMESPACE}:${GITLAB_SERVICE_ACCOUNT}"
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you
save the expanded manifest file for future updates to your app.

```shell
helm template chart/gitlab \
  --name "${APP_INSTANCE_NAME}" \
  --namespace "${NAMESPACE}" \
  --set gitlab.image.repo="${IMAGE_GITLAB}" \
  --set gitlab.image.tag="${TAG}" \
  --set gitlab.rootPassword="${GITLAB_ROOT_PASSWORD}" \
  --set gitlab.serviceAccountName="${GITLAB_SERVICE_ACCOUNT}" \
  --set gitlab.domainName="${DOMAIN_NAME}" \
  --set gitlab.sslConfiguration="${SSL_CONFIGURATION}" \
  --set redis.image="${IMAGE_REDIS}" \
  --set redis.exporter.image="${IMAGE_REDIS_EXPORTER}" \
  --set redis.password="${REDIS_ROOT_PASSWORD}" \
  --set postgresql.image="${IMAGE_POSTGRESQL}" \
  --set postgresql.exporter.image="${IMAGE_POSTGRESQL_EXPORTER}" \
  --set postgresql.password="${POSTGRES_PASSWORD}" \
  --set persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
  --set deployer.image="${IMAGE_DEPLOYER}" \
  --set metrics.image="${IMAGE_METRICS_EXPORTER}" \
  --set tls.base64EncodedPrivateKey="${TLS_CERTIFICATE_KEY}" \
  --set tls.base64EncodedCertificate="${TLS_CERTIFICATE_CRT}" \
  > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Cloud Console URL for your app, run the following
command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

### Access GitLab User Interface

Get the external IP of your GitLab website using the following
command:

```shell
SERVICE_IP="$(kubectl get "service/${APP_INSTANCE_NAME}-gitlab-svc" \
          --namespace "${NAMESPACE}" \
          --output jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "http://${SERVICE_IP}/"
```

Use your GitLab root password generated earlier to sign-in.

# Backup

Below steps are based on [Official GitLab Backup/Restore documentation](https://docs.gitlab.com/ee/raketasks/backup_restore.html#back-up-gitlab) .

```
APP_INSTANCE_NAME=gitlab-1
NAMESPACE=default
```

Run Backup command:
```
kubectl --namespace ${NAMESPACE} exec -it \
  "${APP_INSTANCE_NAME}-gitlab-0" -- bash -c "gitlab-backup create"
```

You can see created backup files from output of backup command or via running:
```
kubectl --namespace ${NAMESPACE} exec -it \
  "${APP_INSTANCE_NAME}-gitlab-0" -- bash -c \
  "ls /var/opt/gitlab/backups/"
```

Copy backup file to local workstation:
```
BACKUP_TAR="<STAMP>_gitlab_backup.tar"

kubectl --namespace ${NAMESPACE} cp \
  ${APP_INSTANCE_NAME}-gitlab-0:/var/opt/gitlab/backups/${BACKUP_TAR} ${BACKUP_TAR}
```

> GitLab does not back up any configuration files, SSL certificates, or
> system files.  You are highly advised to read about storing
> configuration files:
> https://docs.gitlab.com/ee/raketasks/backup_restore.html#storing-configuration-files

Copy secret files manually:
```
for secret in "gitlab-secrets.json" "gitlab.rb"; do
  kubectl --namespace ${NAMESPACE} cp ${APP_INSTANCE_NAME}-gitlab-0:/etc/gitlab/$secret $secret
done
```

Save your root password of this database to local workstation.

```
kubectl --namespace ${NAMESPACE} get secret \
  ${APP_INSTANCE_NAME}-gitlab-secret \
  -ojsonpath='{.data.gitlab-root-password}' > root-password-base64.txt
```

# Restore
For Gitlab Restore Prerequisites visit [here](https://docs.gitlab.com/ee/raketasks/backup_restore.html#restore-prerequisites).

Below steps are based on [Official GitLab Backup/Restore documentation](https://docs.gitlab.com/ee/raketasks/backup_restore.html#restore-for-omnibus-gitlab-installations).

We assume you have below files in local workstation if you followed backup procedure in this document.

- `<STAMP>_gitlab_backup.tar` - Gitlab Backup tar file
- `gitlab.rb` and `gitlab-secrets.json` - Database encryption key related secret files. For more information visit https://docs.gitlab.com/ee/raketasks/backup_restore.html#storing-configuration-files
- `root-password-base64.txt` - File contains encoded root password.

Export mandatory variables.
```
APP_INSTANCE_NAME=gitlab-1
NAMESPACE=default
```
Copy Gitlab Backup tar file to running gitlab instance.
```
BACKUP_TAR="<STAMP>_gitlab_backup.tar"

kubectl --namespace ${NAMESPACE} cp ${BACKUP_TAR} \
  ${APP_INSTANCE_NAME}-gitlab-0:/var/opt/gitlab/backups/
```

Change ownership of file to `git` user.
```
kubectl --namespace ${NAMESPACE} exec -it \
  "${APP_INSTANCE_NAME}-gitlab-0" -- bash -c \
  "chown git:git /var/opt/gitlab/backups/*"
```

Run Restore command and follow the output:
```
kubectl --namespace ${NAMESPACE} exec -it \
  "${APP_INSTANCE_NAME}-gitlab-0" -- bash -c \
  "gitlab-backup restore"
```

Copy Database encryption key related secret files to instance. We assume they are in your current directory.
```
for secret in "gitlab-secrets.json" "gitlab.rb"; do
  kubectl --namespace ${NAMESPACE} cp $secret ${APP_INSTANCE_NAME}-gitlab-0:/etc/gitlab/
done
```

If you deployed with other root password than previous, you should restore it as well.
```
# COPY encoded old password
OLD_PASS=$(cat root-password-base64.txt)

# Patch secret resource with encoded root password
kubectl --namespace $NAMESPACE patch secret \
  $APP_INSTANCE_NAME-gitlab-secret \
  --patch='{"data":{"gitlab-root-password": "'${OLD_PASS}'"}}'
```

# Scaling

This is a single-instance version of GitLab. It is not intended to
be scaled up with its current configuration.

# Upgrade the app

## Prepare the environment

The steps below describe the upgrade procedure with the new version of GitLab Docker image.

> Note that during the upgrade, your GitLab instance will be
unavailable.

Set your environment variables to match the installation properties:

```shell
export APP_INSTANCE_NAME=gitlab-1
export NAMESPACE=default
```

## Upgrade the app

The GitLab StatefulSet is configured to roll out updates
automatically. To start an update, patch the StatefulSet with a
new image reference:

```shell
kubectl set image statefulset "${APP_INSTANCE_NAME}-gitlab" \
  --namespace "${NAMESPACE}" gitlab=[NEW_IMAGE_REFERENCE]
```

where `[NEW_IMAGE_REFERENCE]` is the Docker image reference of the
new image that you want to use.

To check the status of Pods in the StatefulSet, and the progress
of the new image, run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=${APP_INSTANCE_NAME} \
  --namespace "${NAMESPACE}"
```

To verify the current image being used for an `gitlab` container,
run the following command:

```shell
kubectl get statefulset "${APP_INSTANCE_NAME}-gitlab" \
  --namespace "${NAMESPACE}" \
  --output jsonpath='{.spec.template.spec.containers[0].image}'
```

# Uninstall the app

## Using the Google Cloud Console

1.  In the Cloud Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

2. From the list of apps, choose your app installation.

3.  On the Application Details page, click **Delete**.

## Using the command-line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=gitlab-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend using a `kubectl` version that is the same
> as the version of your cluster. Using the same version for `kubectl`
> and the cluster helps to avoid unforeseen issues.

#### Delete the deployment with the generated manifest file

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace ${NAMESPACE}
```

#### Delete the deployment by deleting the Application resource

If you don't have the expanded manifest file, delete the
resources by using types and a label:

```shell
kubectl delete application,statefulset,secret,service,configmap \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

### Delete the persistent volumes of your installation

By design, removing StatefulSets in Kubernetes does not remove any
PersistentVolumeClaims that were attached to their Pods. This
prevents your installations from accidentally deleting stateful data.

To remove the PersistentVolumeClaims with their attached persistent disks, run
the following `kubectl` command:

```shell
kubectl delete persistentvolumeclaims \
  --namespace ${NAMESPACE} \
  --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```
