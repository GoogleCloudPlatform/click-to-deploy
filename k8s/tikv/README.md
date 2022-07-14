# Overview

```shell
export APP_INSTANCE_NAME=tikv
export NAMESPACE=default
export DEFAULT_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
export TIKV_PERSISTENT_DISK_SIZE="2Gi"
export TIKV_TRACK=5.3
export IMAGE_TIKV=gcr.io/ccm-ops-test-adhoc/tikv5
export TIKV_REPLICAS=3
```

```shell
helm template "${APP_INSTANCE_NAME}" chart/tikv \
    --namespace "${NAMESPACE}" \
    --set tikv.image.repo="$IMAGE_TIKV" \
    --set tikv.image.tag="$TIKV_TRACK" \
    --set tikv.persistence.storageClass="${DEFAULT_STORAGE_CLASS}" \
    --set tikv.persistence.size="${TIKV_PERSISTENT_DISK_SIZE}" \
    --set tikv.replicas="${TIKV_REPLICAS:-1}" \
    > "${APP_INSTANCE_NAME}_manifest.yaml"
```

