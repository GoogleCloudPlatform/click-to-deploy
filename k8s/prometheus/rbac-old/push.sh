#!/bin/bash


for i in \
  IMAGE_ALERTMANAGER \
  IMAGE_KUBE_STATE_METRICS \
  IMAGE_NODE_EXPORTER \
  IMAGE_PROMETHEUS \
  IMAGE_PUSHGATEWAY \
  IMAGE_GRAFANA; do
  new_i="$(echo ${!i} | sed 's/cloud-marketplace-ops/orbitera-dev/g')"
  echo OLD: ${!i}
  echo NEW: ${new_i}

  docker pull ${!i}
  docker tag "${!i}" "${new_i}"
  docker push "${new_i}"
done


for i in \
  IMAGE_ALERTMANAGER \
  IMAGE_KUBE_STATE_METRICS \
  IMAGE_NODE_EXPORTER \
  IMAGE_PROMETHEUS \
  IMAGE_PUSHGATEWAY \
  IMAGE_GRAFANA; do
  new_i="$(echo ${!i} | sed 's/cloud-marketplace-ops/orbitera-dev/g')"
  echo $i=\""${new_i}"\"
done