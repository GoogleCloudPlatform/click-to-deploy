#!/bin/bash

declare -r VERSION=0.54.1
declare -r REPO_URL="https://raw.githubusercontent.com/prometheus-operator/prometheus-operator"
declare -r CRD_PATH="example/prometheus-operator-crd"

# Apply CRDs
kubectl apply -f "${REPO_URL}/v${VERSION}/${CRD_PATH}/monitoring.coreos.com_alertmanagerconfigs.yaml"
kubectl apply -f "${REPO_URL}/v${VERSION}/${CRD_PATH}/monitoring.coreos.com_alertmanagers.yaml"
kubectl apply -f "${REPO_URL}/v${VERSION}/${CRD_PATH}/monitoring.coreos.com_podmonitors.yaml"
kubectl apply -f "${REPO_URL}/v${VERSION}/${CRD_PATH}/monitoring.coreos.com_probes.yaml"
kubectl apply -f "${REPO_URL}/v${VERSION}/${CRD_PATH}/monitoring.coreos.com_prometheuses.yaml" \
  --force-conflicts=true --server-side
kubectl apply -f "${REPO_URL}/v${VERSION}/${CRD_PATH}/monitoring.coreos.com_prometheusrules.yaml"
kubectl apply -f "${REPO_URL}/v${VERSION}/${CRD_PATH}/monitoring.coreos.com_servicemonitors.yaml"
kubectl apply -f "${REPO_URL}/v${VERSION}/${CRD_PATH}/monitoring.coreos.com_thanosrulers.yaml"

# Wait for resources
crds=(
  alertmanagerconfigs.monitoring.coreos.com
  alertmanagers.monitoring.coreos.com
  podmonitors.monitoring.coreos.com
  probes.monitoring.coreos.com
  prometheuses.monitoring.coreos.com
  prometheusrules.monitoring.coreos.com
  servicemonitors.monitoring.coreos.com
  thanosrulers.monitoring.coreos.com
)

for crd in ${crds[@]}; do
  kubectl wait --for=condition=Established --timeout=15s crd "${crd}"
done
