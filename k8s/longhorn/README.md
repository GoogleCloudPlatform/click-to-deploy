# Overview

Knative is an Open-Source Enterprise-level solution to build Serverless and Event Driven Applications

For more information, visit the Knative [official website](https://knative.dev/).

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Architecture

![Architecture diagram](resources/knative-k8s-app-architecture.png)

This app offers "list of resources".

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! To install this Knative app to a
Google Kubernetes Engine cluster via Google Cloud Marketplace, follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/knative).

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

Create a new cluster from the command-line:

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

Clone this repo, and its associated tools repo:

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
community. You can find the source code at
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the app

Navigate to the `longhorn` directory:

```shell
cd click-to-deploy/k8s/longhorn
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=longhorn
export NAMESPACE=default
```

```shell
export TRACK_MANAGER=v1.3.x-head
export TRACK_LONGHORN=v1.3.2
export TRACK_CSI_ATTACHER=v3.4.0
export TRACK_CSI_PROVISIONER=v2.1.2
export TRACK_CSI_NODE_DRIVER_REGISTRAR=v2.5.0
export TRACK_CSI_RESIZER=v1.2.0
export TRACK_CSI_SNAPSHOTTER=v3.0.3

```

Configure the container images:

```shell
export IMAGE_LONGHORN_ENGINE=docker.io/longhornio/longhorn-engine
export IMAGE_LONGHORN_MANAGER=docker.io/longhornio/longhorn-manager
export IMAGE_LONGHORN_UI=docker.io/longhornio/longhorn-ui
export IMAGE_LONGHORN_INSTANCE_MANAGER=docker.io/longhornio/longhorn-instance-manager
export IMAGE_LONGHORN_SHARE_MANAGER=docker.io/longhornio/longhorn-share-manager
export IMAGE_LONGHORN_BACKING_IMAGE_MANAGER=docker.io/longhornio/backing-image-manager
export IMAGE_LONGHORN_CSI_ATTACHER=docker.io/longhornio/csi-attacher
export IMAGE_LONGHORN_CSI_PROVISIONER=docker.io/longhornio/csi-provisioner
export IMAGE_LONGHORN_CSI_NODE_DRIVER_REGISTRAR=docker.io/longhornio/csi-node-driver-registrar
export IMAGE_LONGHORN_CSI_RESIZER=docker.io/longhornio/csi-resizer
export IMAGE_LONGHORN_CSI_SNAPSHOTTER=docker.io/longhornio/csi-snapshotter
```

```shell
export LONGHORN_MANAGER_REPLICAS=1
export LONGHORN_CSI_ATTACHER_REPLICAS=1
export LONGHORN_CSI_PROVISIONER_REPLICAS=1
export LONGHORN_CSI_SNAPSHOTTER_REPLICAS=1
export LONGHORN_CSI_RESIZER_REPLICAS=1

```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template "${APP_INSTANCE_NAME}" chart/longhorn \
    --namespace "${NAMESPACE}" \
    --set longhorn.engine.image.repo="${IMAGE_LONGHORN_ENGINE}" \
    --set longhorn.engine.image.tag="${TRACK_LONGHORN}" \
    --set longhorn.manager.image.repo="${IMAGE_LONGHORN_MANAGER}" \
    --set longhorn.manager.image.tag="${TRACK_LONGHORN}" \
    --set longhorn.ui.image.repo="${IMAGE_LONGHORN_UI}" \
    --set longhorn.ui.image.tag="${TRACK_LONGHORN}" \
    --set longhorn.instancemanager.image.repo="${IMAGE_LONGHORN_INSTANCE_MANAGER}" \
    --set longhorn.instancemanager.image.tag="${TRACK_MANAGER}" \
    --set longhorn.sharemanager.image.repo="${IMAGE_LONGHORN_SHARE_MANAGER}" \
    --set longhorn.sharemanager.image.tag="${TRACK_MANAGER}" \
    --set longhorn.backingimagemanager.image.repo="${IMAGE_LONGHORN_BACKING_IMAGE_MANAGER}" \
    --set longhorn.backingimagemanager.image.tag="${TRACK_MANAGER}" \
    --set longhorn.csiattacher.image.repo="${IMAGE_LONGHORN_CSI_ATTACHER}" \
    --set longhorn.csiattacher.image.tag="${TRACK_CSI_ATTACHER}" \
    --set longhorn.csiprovisioner.image.repo="${IMAGE_LONGHORN_CSI_PROVISIONER}" \
    --set longhorn.csiprovisioner.image.tag="${TRACK_CSI_PROVISIONER}" \
    --set longhorn.csinodedriverregistrar.image.repo="${IMAGE_LONGHORN_CSI_NODE_DRIVER_REGISTRAR}" \
    --set longhorn.csinodedriverregistrar.image.tag="${TRACK_CSI_NODE_DRIVER_REGISTRAR}" \
    --set longhorn.csiresizer.image.repo="${IMAGE_LONGHORN_CSI_RESIZER}" \
    --set longhorn.csiresizer.image.tag="${TRACK_CSI_RESIZER}" \
    --set longhorn.csisnapshotter.image.repo="${IMAGE_LONGHORN_CSI_SNAPSHOTTER}" \
    --set longhorn.csisnapshotter.image.tag="${TRACK_CSI_SNAPSHOTTER}" \
    --set longhorn.manager.replicas="${LONGHORN_MANAGER_REPLICAS:-1}" \
    --set longhorn.csiattacher.replicas="${LONGHORN_CSI_ATTACHER_REPLICAS:-1}" \
    --set longhorn.csiprovisioner.replicas="${LONGHORN_CSI_PROVISIONER_REPLICAS:-1}" \
    --set longhorn.csisnapshotter.replicas="${LONGHORN_CSI_SNAPSHOTTER_REPLICAS:-1}" \
    --set longhorn.csiresizer.replicas="${LONGHORN_CSI_RESIZER_REPLICAS:-1}" \
    > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f ${APP_INSTANCE_NAME}_manifest.yaml
```

In case of such errors:
```
unable to recognize "/data/resources.yaml": no matches for kind "EnvoyFilter" in version "networking.istio.io/v1alpha3"
unable to recognize "/data/resources.yaml": no matches for kind "Gateway" in version "networking.istio.io/v1alpha3"
unable to recognize "/data/resources.yaml": no matches for kind "Image" in version "caching.internal.knative.dev/v1alpha1"
unable to recognize "/data/resources.yaml": no matches for kind "PeerAuthentication" in version "security.istio.io/v1beta1"
```
re-apply the manifest.

The solution contains several CRDs. Install them before installing the manifest:

```shell
kubectl apply -f ./chart/knative/templates/crds/
kubectl apply -f ${APP_INSTANCE_NAME}_manifest.yaml
```

#### View the app in the Google Cloud Console

To get the Cloud Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

#### Get the ingress public address

To get the Istio IngressGateway public ip, run the following command:

```shell
export INGRESS_GATEWAY=$(kubectl get svc istio-ingressgateway --namespace $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $INGRESS_GATEWAY
```

#### Deploy your first knative app

By default, Knative Serving routes use `example.com` as the default domain.
The fully qualified domain name for a route by default is `{route}.{namespace}.{default-domain}`.

To change the {default-domain} value there are a few steps involved:

##### Edit using kubectl

- Edit the domain configuration config-map to replace `example.com` with your own domain, for example `mydomain.com`:

```shell
kubectl edit cm config-domain --namespace $NAMESPACE
```

This command opens your default text editor and allows you to edit the config map. 

```yaml
apiVersion: v1
data:
  example.com: ""
kind: ConfigMap
[...]
```

- Edit the file to replace `example.com` with the new domain and save your changes. In this example, we configure `mydomain.com` for all routes: 

```yaml
apiVersion: v1
data:
  mydomain.com: ""
kind: ConfigMap
[...]
```

##### Apply from a file

You can also apply an updated domain configuration:

- Create a new file, `config-domain.yaml` and paste the following text, replacing the `example.org` and `example.com` values with the new domain you want to use:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-domain
data:
  # These are example settings of domain.
  # example.org will be used for routes having app=prod.
  example.org: |
    selector:
      app: prod
  # Default value for domain, for routes that does not have app=prod labels.
  # Although it will match all routes, it is the least-specific rule so it
  # will only be used if no other domain matches.
  example.com: ""
```

- Apply updated domain configuration to your cluster:

```shell
kubectl apply -f config-domain.yaml --namespace $NAMESPACE
```

Deploy an app (for example, `helloworld-go`), to your cluster as normal. 

- Create a new file, `helloworld-go.yaml` and paste the following text:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-go
spec:
  template:
    metadata:
      name: helloworld-go-v1
    spec:
      containers:
        - image: gcr.io/knative-samples/helloworld-go
          ports:
            - containerPort: 8080
          env:
            - name: TARGET
              value: "knative"
```

You can check the custom domain in Knative Route "helloworld-go" with
the following command:

```shell
kubectl get route helloworld-go --output jsonpath="{.status.domain}" --namespace $NAMESPACE
```
You should view the full customized domain: `helloworld-go.$NAMESPACE.yourdomain.com`.

You can map the domain to the IP address of your Knative gateway in your local 
machine with:

```shell
export INGRESS_GATEWAY=$(kubectl get svc istio-ingressgateway --namespace $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export DOMAIN_NAME=$(kubectl get route helloworld-go --output jsonpath="{.status.domain}" --namespace $NAMESPACE)
# Add the record of Gateway IP and domain name into file "/etc/hosts"
echo -e "$INGRESS_GATEWAY\t$DOMAIN_NAME" | sudo tee -a /etc/hosts
```

You can now access your domain from the browser in your machine and do some quick checks.

#### Publish your domain

To publish your domain, you need to update your DNS provider to point to the IP address for your service ingress.

- Create a [wildcard record](https://support.google.com/domains/answer/4633759)
for the namespace and custom domain to the ingress IP Address, which would enable 
hostnames for multiple services in the same namespace to work without creating additional DNS entries.
For example, your ingress Ip is `35.237.28.44` and namespace is `default`.


```dns
*.default.yourdomain.com                   59     IN     A   35.237.28.44
```

- Create an A record to point from the fully qualified domain name to the IP address of your Knative gateway. 
This step needs to be done for each Knative Service or Route created.
  
```dns
helloworld-go.default.yourdomain.com        59     IN     A   35.237.28.44
```

If you are using Google Cloud DNS, you can find step-by-step instructions
in the [Quickstart](https://cloud.google.com/dns/quickstart).


Once the domain update has propagated, you can access your app using 
the fully qualified domain name of the deployed route.

# Scaling up or down

To change the number of replicas of the `Cert Manager controller`, use the following
command, where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment cert-manager --namespace $NAMESPACE --replicas=$REPLICAS
```

To change the number of replicas of `Cert Manager cainjector`, use the following command,
where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment cert-manager-cainjector --namespace $NAMESPACE --replicas=$REPLICAS
```

To change the number of replicas of the `Cert Manager webhook`, use the following command,
where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment cert-manager-webhook --namespace $NAMESPACE --replicas=$REPLICAS
```

To change the number of replicas of `Istio IngressGateway`, use the following command,
where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment istio-ingressgateway --namespace $NAMESPACE --replicas=$REPLICAS
```

To change the number of replicas of the `Knative autoscaler`, use the following command,
where `REPLICAS` is your desired number of replicas:

```shell
export REPLICAS=3
kubectl scale deployment autoscaler --namespace $NAMESPACE --replicas=$REPLICAS
```

# Back up and restore

## Back up Knative configuration data to your local environment

To back up Knative configuration resources and issued certificates, use the following command:

```shell
kubectl get --namespace $NAMESPACE --output=yaml \
configmaps,kservice,issuer,clusterissuer,certificates,certificaterequests > backup_file.yaml
```

## Restore Knative configuration data from your local environment

```shell
kubectl apply -f backup_file.yaml
```

# Uninstall the app

## Using the Google Cloud Console

- In the Cloud Console, open
   [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

- From the list of apps, click **Knative**.

- On the Application Details page, click **Delete**.

## Using the command-line

### Prepare your environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=knative
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** We recommend that you use a `kubectl` version that is the same
> version as that of your cluster. Using the same versions for `kubectl` and
> the cluster helps to avoid unforeseen issues.

To delete the resources, use the expanded manifest file used for the
installation.

Run `kubectl` on the expanded manifest file:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

You can also delete the resources by using types and a label:

```shell
kubectl delete application --namespace $NAMESPACE --selector app.kubernetes.io/name=${APP_INSTANCE_NAME}
```

**NOTE:** This will delete only the `knative` solution. All `knative`-managed resources will remain available.

### Delete the GKE cluster

If you don't need the deployed app or the GKE cluster, delete the cluster
by using this command:

```shell
gcloud container clusters delete "${CLUSTER}" --zone "${ZONE}"
```

