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

Navigate to the `knative` directory:

```shell
cd click-to-deploy/k8s/knative
```

#### Configure the app with environment variables

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=knative
export NAMESPACE=default
```

Set up the image tag:

It is advised to use a stable image reference, which you can find on:
- [Cert Manager - Marketplace Container Registry](https://marketplace.gcr.io/google/cert-manager1).
- [Knative - Marketplace Container Registry](https://marketplace.gcr.io/google/knative1).
- [Istio - Google Container Registry](https://gcr.io/istio-release/proxyv2)
For example:

```shell
export TRACK_CERT_MANAGER=1.11
export TRACK_ISTIO=1.16.0
export TRACK_KNATIVE=v1.9.0
```

Configure the container images:

```shell
export IMAGE_CERT_MANAGER=marketplace.gcr.io/google/cert-manager1
export IMAGE_ISTIO_INGRESSGATEWAY=gcr.io/istio-release/proxyv2
export IMAGE_ISTIO_ISTIOD=gcr.io/istio-release/pilot
export IMAGE_KNATIVE_SERVING_ACTIVATOR=gcr.io/knative-releases/knative.dev/serving/cmd/activator
export IMAGE_KNATIVE_SERVING_AUTOSCALER=gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler
export IMAGE_KNATIVE_SERVING_CONTROLLER=gcr.io/knative-releases/knative.dev/serving/cmd/controller
export IMAGE_KNATIVE_SERVING_DOMAINMAPPING=gcr.io/knative-releases/knative.dev/serving/cmd/domain-mapping
export IMAGE_KNATIVE_SERVING_DOMAINMAPPING_WEBHOOK=gcr.io/knative-releases/knative.dev/serving/cmd/domain-mapping-webhook
export IMAGE_KNATIVE_SERVING_QUEUEPROXY=gcr.io/knative-releases/knative.dev/serving/cmd/queue
export IMAGE_KNATIVE_SERVING_WEBHOOK=gcr.io/knative-releases/knative.dev/serving/cmd/webhook
export IMAGE_KNATIVE_SERVING_NETCERMANAGER_CONTROLLER=gcr.io/knative-releases/knative.dev/net-certmanager/cmd/controller
export IMAGE_KNATIVE_SERVING_NETCERMANAGER_WEBHOOK=gcr.io/knative-releases/knative.dev/net-certmanager/cmd/webhook
export IMAGE_KNATIVE_SERVING_NETISTIO_CONTROLLER=gcr.io/knative-releases/knative.dev/net-istio/cmd/controller
export IMAGE_KNATIVE_SERVING_NETISTIO_WEBHOOK=gcr.io/knative-releases/knative.dev/net-istio/cmd/webhook
export IMAGE_KNATIVE_EVENTING_CONTROLLER=gcr.io/knative-releases/knative.dev/eventing/cmd/controller
export IMAGE_KNATIVE_EVENTING_MTPING=gcr.io/knative-releases/knative.dev/eventing/cmd/mtping
export IMAGE_KNATIVE_EVENTING_WEBHOOK=gcr.io/knative-releases/knative.dev/eventing/cmd/webhook
```

By default, each deployment has 1 replica, but you can choose to set the
number of replicas for:
- Cert Manager controller, webhook and cainjector.
- Istio ingress gateway.
- Knative autoscaler.

```shell
export CERT_MANAGER_CONTROLLER_REPLICAS=3
export CERT_MANAGER_WEBHOOK_REPLICAS=3
export CERT_MANAGER_CAINJECTOR_REPLICAS=3
export ISTIO_INGRESS_GATEWAY_REPLICAS=3
export KNATIVE_AUTOSCALER_REPLICAS=3
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template "${APP_INSTANCE_NAME}" chart/knative \
    --namespace "${NAMESPACE}" \
    --set certmanager.image.repo="$IMAGE_CERT_MANAGER" \
    --set certmanager.image.tag="$TRACK_CERT_MANAGER" \
    --set istio.ingressgateway.image.repo="$IMAGE_ISTIO_INGRESSGATEWAY" \
    --set istio.ingressgateway.image.tag="$TRACK_ISTIO" \
    --set istio.istiod.image.repo="$IMAGE_ISTIO_ISTIOD" \
    --set istio.istiod.image.tag="$TRACK_ISTIO" \
    --set knative.serving.activator.image.repo="$IMAGE_KNATIVE_SERVING_ACTIVATOR" \
    --set knative.serving.activator.image.tag="$TRACK_KNATIVE" \
    --set knative.serving.autoscaler.image.repo="$IMAGE_KNATIVE_SERVING_AUTOSCALER" \
    --set knative.serving.autoscaler.image.tag="$TRACK_KNATIVE" \
    --set knative.serving.controller.image.repo="$IMAGE_KNATIVE_SERVING_CONTROLLER" \
    --set knative.serving.controller.image.tag="$TRACK_KNATIVE" \
    --set knative.serving.domainmapping.image.repo="$IMAGE_KNATIVE_SERVING_DOMAINMAPPING" \
    --set knative.serving.domainmapping.image.tag="$TRACK_KNATIVE" \
    --set knative.serving.domainmapping.webhook.image.repo="$IMAGE_KNATIVE_SERVING_DOMAINMAPPING_WEBHOOK" \
    --set knative.serving.domainmapping.webhook.image.tag="$TRACK_KNATIVE" \
    --set knative.serving.queueproxy.image.repo="$IMAGE_KNATIVE_SERVING_QUEUEPROXY" \
    --set knative.serving.queueproxy.image.tag="$TRACK_KNATIVE" \
    --set knative.serving.webhook.image.repo="$IMAGE_KNATIVE_SERVING_WEBHOOK" \
    --set knative.serving.webhook.image.tag="$TRACK_KNATIVE" \
    --set knative.serving.netcertmanager.controller.image.repo="$IMAGE_KNATIVE_SERVING_NETCERMANAGER_CONTROLLER" \
    --set knative.serving.netcertmanager.controller.image.tag="$TRACK_KNATIVE" \
    --set knative.serving.netcertmanager.webhook.image.repo="$IMAGE_KNATIVE_SERVING_NETCERMANAGER_WEBHOOK" \
    --set knative.serving.netcertmanager.webhook.image.tag="$TRACK_KNATIVE" \
    --set knative.serving.netistio.controller.image.repo="$IMAGE_KNATIVE_SERVING_NETISTIO_CONTROLLER" \
    --set knative.serving.netistio.controller.image.tag="$TRACK_KNATIVE" \
    --set knative.serving.netistio.webhook.image.repo="$IMAGE_KNATIVE_SERVING_NETISTIO_WEBHOOK" \
    --set knative.serving.netistio.webhook.image.tag="$TRACK_KNATIVE" \
    --set knative.eventing.controller.image.repo="$IMAGE_KNATIVE_EVENTING_CONTROLLER" \
    --set knative.eventing.controller.image.tag="$TRACK_KNATIVE" \
    --set knative.eventing.mtping.image.repo="$IMAGE_KNATIVE_EVENTING_MTPING" \
    --set knative.eventing.mtping.image.tag="$TRACK_KNATIVE" \
    --set knative.eventing.webhook.image.repo="$IMAGE_KNATIVE_EVENTING_WEBHOOK" \
    --set knative.eventing.webhook.image.tag="$TRACK_KNATIVE" \
    --set certmanager.controller.replicas="${CERT_MANAGER_CONTROLLER_REPLICAS:-1}" \
    --set certmanager.webhook.replicas="${CERT_MANAGER_WEBHOOK_REPLICAS:-1}" \
    --set certmanager.cainjector.replicas="${CERT_MANAGER_CAINJECTOR_REPLICAS:-1}" \
    --set istio.ingressgateway.replicas="${ISTIO_INGRESS_GATEWAY_REPLICAS:-1}" \
    --set knative.autoscaler.replicas="${KNATIVE_AUTOSCALER_REPLICAS:-1}" \
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

