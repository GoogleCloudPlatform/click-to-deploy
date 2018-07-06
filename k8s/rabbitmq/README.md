# Overview

RabbitMQ is an open source messaging system that implements the Advanced
Message Queueing Protocol to serve a variety of messaging applications.

[Learn more](https://www.rabbitmq.com/)

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this RabbitMQ app to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/launcher/details/google/rabbitmq).

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
export PROJECT=your-gcp-project # or export PROJECT=$(gcloud config get-value project)
export CLUSTER=marketplace-cluster
export ZONE=us-west1-a # or export ZONE=$(gcloud config get-value compute/zone)

gcloud --project "$PROJECT" container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to talk to the new cluster.

```shell
gcloud --project "$PROJECT" container clusters get-credentials "$CLUSTER" --zone "$ZONE"
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
kubectl apply -f marketplace-tools/crd/app-crd.yaml
```

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `rabbitmq` directory.

```shell
cd google-click-to-deploy/k8s/rabbitmq
```

#### Configure the app with environment variables

Choose the instance name and namespace for the app.

```shell
export APP_INSTANCE_NAME=rabbitmq-1
export NAMESPACE=default
```

Set the number of replicas.

```shell
export REPLICAS=3
```

Set or generate the [Erlang cookie](https://www.rabbitmq.com/clustering.html#erlang-cookie). The cookie has be encoded in base64.

```shell
export RABBITMQ_ERLANG_COOKIE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 | tr -d '\n' | base64)
```

Set username of the app.

```shell
export RABBITMQ_DEFAULT_USER=rabbit
```

Set or generate the password. The value has to be encoded in base64.

```shell
export RABBITMQ_DEFAULT_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1 | tr -d '\n' | base64)
```

Configure the container images.

```shell
export IMAGE_RABBITMQ=gcr.io/k8s-marketplace-eap/google/rabbitmq3:latest
```

The images above are referenced by
[tag](https://docs.docker.com/engine/reference/commandline/tag). It is strongly
recommended to pin each image to an immutable
[content digest](https://docs.docker.com/registry/spec/api/#content-digests).
This will ensure that the installed application will always use the same images,
until you are ready to upgrade.

```shell
for i in "IMAGE_RABBITMQ"; do
  repo=`echo ${!i} | cut -d: -f1`;
  digest=`docker pull ${!i} | sed -n -e 's/Digest: //p'`;
  export $i="$repo@$digest";
  env | grep $i;
done
```

#### Prerequisites for using Role-Based Access Control

You must grant your user the ability to create roles in Kubernetes by running the following command. You have to do it **once** for the cluster. [Read more](https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control)

```shell
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)
```

#### Expand the manifest template

Use `envsubst` to expand the template. It is recommended that you save the
expanded manifest file for future updates to the application.

```shell
awk 'BEGINFILE {print "---"}{print}' manifest/* \
  | envsubst '$APP_INSTANCE_NAME $NAMESPACE $IMAGE_RABBITMQ $REPLICAS $RABBITMQ_ERLANG_COOKIE $RABBITMQ_DEFAULT_USER $RABBITMQ_DEFAULT_PASS' \
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

#### Cluster status

By default, the application does not have an external IP. Use `kubectl` to execute `rabbitmqctl` on the master node.

```
kubectl exec -it "$APP_INSTANCE_NAME-rabbitmq-0" --namespace "$NAMESPACE" -- rabbitmqctl cluster_status
```

#### Authorization

The default username is `rabbit`. Use `kubectl` to get the generated password.

```shell
kubectl get secret $APP_INSTANCE_NAME-rabbitmq-secret \
  --namespace $NAMESPACE \
  --output=jsonpath='{.data.rabbitmq-pass}' | base64 --decode
```

#### Expose RabbitMQ service (optional)

By default, the application does not have an external IP. Run the
following command to expose an external IP:

> **NOTE:** It might take some time for the external IP to be provisioned.

```
kubectl patch svc "$APP_INSTANCE_NAME-rabbitmq-svc" \
  --namespace "$NAMESPACE" \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

#### Access RabbitMQ service

**Option 1:** To discover IP addresses of RabbitMQ service using `kubectl`, run the following command:

```
kubectl get svc $APP_INSTANCE_NAME-rabbitmq-svc --namespace $NAMESPACE
```

**Option 2:** If you run your RabbitMQ cluster behind a LoadBalancer, run the command below to get an external IP of the RabbitMQ service:

```
SERVICE_IP=$(kubectl get svc $APP_INSTANCE_NAME-rabbitmq-svc \
  --namespace $NAMESPACE \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}'); \
echo "http://${SERVICE_IP}:15672"
```

Navigate http://`<EXTERNAL-IP>`:15672 to access RabbitMQ Management UI. Where `<EXTERNAL-IP>` is provided by command above.

**Option 3:** Use Port Forwarding:

```
kubectl port-forward svc/$APP_INSTANCE_NAME-rabbitmq-svc --namespace $NAMESPACE 15672
```

Navigate http://127.0.0.1:15672 to access RabbitMQ Management UI.

**Option 4:** If you would like to get cluster IP and external IP addressses of RabbitMQ service using Python you could use the following code:

```python
import os

# if kubernetes module is not installed, please, install it, e.g. pip install kubernetes
from kubernetes import client, config

# Load Kube config
config.load_kube_config()

# Create a Kubernetes client
k8s_client = client.CoreV1Api()

# Get the list of all pods
service = k8s_client.read_namespaced_service(namespace="default", name="rabbitmq-1-rabbitmq-svc")

print("Cluster IP: {}\n".format(service.spec.cluster_ip))

for item in service.status.load_balancer.ingress:
  print("External IP: {}\n".format(item.ip))
```

If you would like to send and receive messages to RabbitMQ using Python [here](https://www.rabbitmq.com/tutorials/tutorial-one-python.html) is a good reference how to do that.

#### Scale the cluster

By default, RabbitMQ K8s application is deployed using 3 replicas. You can manually scale it up or down using the following command.

> **NOTE:** Scaling down will leave `persistentvolumeclaims` of your StatefulSet untouched.

```
kubectl scale statefulsets "$APP_INSTANCE_NAME-rabbitmq" \
  --namespace "$NAMESPACE" --replicas=<new-replicas>
```

where `<new-replicas>` defines the number of replicas.

# Backup and restore

TODO

# Update procedure

For more background about the rolling update procedure, check the [Upgrading RabbitMQ](https://www.rabbitmq.com/upgrade.html) guide.

Start with assigning a new image to your StatefulSet definition:

```shell
kubectl set image statefulset "$APP_INSTANCE_NAME-rabbitmq" \
  rabbitmq=<put-your-new-image-reference-here>
```

where `<put-your-new-image-reference-here>` is the new image.

To check that the Pods in the StatefulSet running the `rabbitmq` container are updating, run the following command:

```shell
kubectl get pods -l app.kubernetes.io/name=$APP_INSTANCE_NAME -w
```

The Pods in the StatefulSet are updated in reverse ordinal order.
The StatefulSet controller terminates each Pod, and waits for it to transition to `Running` and `Ready` prior to updating the next Pod.
The final state of the Pods should be `Running` and marked as `1/1` in **READY** column.

To check the current image used for `rabbitmq` container, you can run the following command:

```shell
kubectl get statefulsets "$APP_INSTANCE_NAME-rabbitmq" \
  --namespace "$NAMESPACE" \
  --output jsonpath='{.spec.template.spec.containers[0].image}'
```

# Uninstall the Application

## Using GKE UI

Navigate to `GKE > Applications` in GCP console. From the list of applications, click on the one
that you wish to uninstall.

On the new screen, click on the `Delete` button located in the top menu. It will remove
the resources attached to this application.

## Using the command line

### Prepare the environment

Set your installation name and Kubernetes namespace:

```shell
export APP_INSTANCE_NAME=rabbitmq-1
export NAMESPACE=default
```

### Delete the resources

> **NOTE:** Please keep in mind that `kubectl` guarantees support for Kubernetes server in +/- 1 versions. It means that for instance if you have kubectl in version `1.10.*` and Kubernetes server `1.8.*`, you may experience incompatibility issues, like not removing the *StatefulSets* with apiVersion of *apps/v1beta2*.

If you still have the expanded manifest file used for the installation, you can use it to delete the resources.
Run `kubectl` on expanded manifest file matching your installation:

```shell
kubectl delete -f ${APP_INSTANCE_NAME}_manifest.yaml --namespace $NAMESPACE
```

Otherwise, delete the resources by indication types and label:

```shell
kubectl delete statefulset,secret,service,configmap,serviceaccount,role,rolebinding,application \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete the persistent volumes of your installation

By design, removal of *StatefulSets* in Kubernetes does not remove the *PersistentVolumeClaims* that
were attached to their Pods. It protects your installations from mistakenly deleting stateful data.

If you wish to remove the *PersistentVolumeClaims* with their attached persistent disks, run the
following `kubectl` commands:

```shell
for i in $(kubectl get pvc --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME \
  --output jsonpath='{.items[*].spec.volumeName}');
do
  kubectl delete pv/$i --namespace $NAMESPACE
done

kubectl delete persistentvolumeclaims \
  --namespace $NAMESPACE \
  --selector app.kubernetes.io/name=$APP_INSTANCE_NAME
```

### Delete GKE cluster

Optionally, if you do not need both the deployed application and GKE cluster used for deployment then you can delete the whole GKE cluster using this command:

```shell
export PROJECT=your-gcp-project # or export PROJECT=$(gcloud config get-value project)
export CLUSTER=marketplace-cluster
export ZONE=us-west1-a # or export ZONE=$(gcloud config get-value compute/zone)
```

```
gcloud --project "$PROJECT" container clusters delete "$CLUSTER" --zone "$ZONE"
```
