# keycloak

```shell
export APP_INSTANCE_NAME=keycloak
export NAMESPACE=default
```

For the persistent disk provisioning of the PostgreSQL StatefulSet and NFS Shared Volume, you will need to:

- Set the StorageClass name. Check your available options using the command below:
  * ```kubectl get storageclass```
  * Or check how to create a new StorageClass in [Kubernetes Documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#the-storageclass-resource)

- Set the persistent disks size. The default disks size is "5Gi".

```shell
export DEFAULT_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export PSQL_PERSISTENT_DISK_SIZE="5Gi"
```

Set up the image tag:

It is advised to use a stable image reference, which you can find on:
- [Apache Airflow - Marketplace Container Registry](https://gcr.io/ccm-ops-test-adhoc/keycloak18).
- [PostgreSQL - Marketplace Container Registry](https://marketplace.gcr.io/google/postgresql13).
For example:

```shell
export KEYCLOAK_TRACK=18.0
export POSTGRESQL_TRACK=13.4
export METRICS_EXPORTER_TAG=0.5
```

Configure the container images:

```shell
export IMAGE_KEYCLOAK=gcr.io/cloud-marketplace-ops/keycloak18
export IMAGE_POSTGRESQL=marketplace.gcr.io/google/postgresql13
export IMAGE_METRICS_EXPORTER=k8s.gcr.io/prometheus-to-sd:${METRICS_EXPORTER_TAG}
```

By default, each deployment has 1 replica, but you can choose to set the
number of replicas for Airflow webserver, scheduler and triggerer.

```shell
export KEYCLOAK_REPLICAS=1 
```

Set or generate the UI password:

```shell
export KEYCLOAK_ADMIN_PASSWORD="admin_password"
```

(Optional) Expose the Service externally and configure Ingress:

By default, the Service is not exposed externally. To enable this option, change the value to true.

```shell
export PUBLIC_SERVICE_AND_INGRESS_ENABLED=false
```

(Optional) Enable Stackdriver Metrics Exporter:

> **NOTE:** Your GCP project must have Stackdriver enabled. If you are using a
> non-GCP cluster, you cannot export metrics to Stackdriver.

By default, the application does not export metrics to Stackdriver. To enable
this option, change the value to `true`.

```shell
export METRICS_EXPORTER_ENABLED=false
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template "${APP_INSTANCE_NAME}" chart/keycloak \
    --namespace "${NAMESPACE}" \
    --set keycloak.image.repo="$IMAGE_KEYCLOAK" \
    --set keycloak.image.tag="$KEYCLOAK_TRACK" \
    --set postgresql.image.repo="$IMAGE_POSTGRESQL" \
    --set postgresql.image.tag="$POSTGRESQL_TRACK" \
    --set postgresql.persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
    --set postgresql.persistence.size="${PSQL_PERSISTENT_DISK_SIZE}" \
    --set keycloak.replicas="${KEYCLOAK_REPLICAS:-1}" \
    --set keycloak.admin.password="${KEYCLOAK_ADMIN_PASSWORD}" \
    --set enablePublicServiceAndIngress="${PUBLIC_SERVICE_AND_INGRESS_ENABLED}" \
    --set metrics.image="$IMAGE_METRICS_EXPORTER" \
    --set metrics.exporter.enabled="$METRICS_EXPORTER_ENABLED" \
    > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```
