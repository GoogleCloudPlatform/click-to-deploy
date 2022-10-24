#!/bin/bash

# Install Argo Events

# git clone https://github.com/argoproj/argo-workflows.git --branch "v3.4.1"

# # Install Argo Workflows CRDs
# declare -r crd_folder="argo-workflows/manifests/base/crds/minimal"
# for manifest in $(ls -1 ${crd_folder}/*.yaml | grep -v "kustomization"); do
#   kubectl apply -f "${manifest}"
# done


declare argoevents_version="$(cat argo-workflows/go.mod \
                              | grep "argo-events" \
                              | grep -P -o "v(\d+)\.(\d+).(\d)$")"

git clone https://github.com/argoproj/argo-events.git --branch "${argoevents_version}"

# Install Argo Workflows CRDs
declare -r crd_folder="argo-events/manifests/base/crds"
for manifest in $(ls -1 ${crd_folder}/*.yaml | grep -v "kustomization"); do
  kubectl apply -f "${manifest}"
done

# rm -rf argo-events/
# rm -rf argo-workflows/
