#!/bin/bash

declare -r REPO_URL="https://raw.githubusercontent.com/prometheus-operator/prometheus-operator"
declare -r CRD_PATH="example/prometheus-operator-crd"
declare -a CRDS=(
  alertmanagerconfigs
  alertmanagers
  podmonitors
  probes
  prometheuses
  prometheusrules
  servicemonitors
  thanosrulers
)

# Apply CRDs
for crd in ${CRDS[@]}; do
  kubectl apply -f "${REPO_URL}/v${VERSION}/${CRD_PATH}/monitoring.coreos.com_${crd}.yaml" \
    --force-conflicts=true --server-side
done

# Wait for resources
for crd in ${CRDS[@]}; do
  kubectl wait --for=condition=Established --timeout=15s crd "${crd}.monitoring.coreos.com"
done
