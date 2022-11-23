#!/bin/bash
#
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

declare -r argo_version="$(yaml2json chart/argo-workflows/values.yaml \
                            | jq -r '.argo_workflows.version')"

# Download CRDs
echo "### Downloading CRDs..."
git clone https://github.com/argoproj/argo-workflows.git --branch "${argo_version}" \
  && rm -f argo-workflows/manifests/base/crds/minimal/kustomization.yaml \
  && rm -f argo-workflows/manifests/base/crds/minimal/README.md \
  && argoevents_version="$(cat argo-workflows/go.mod | grep "argo-events" | grep -P -o "v(\d+)\.(\d+).(\d)$")" \
  && git clone https://github.com/argoproj/argo-events.git --branch "${argoevents_version}" \
  && rm -f argo-events/manifests/base/crds/kustomization.yaml

# Apply the CRDs
echo "### Applying CRDs..."
kubectl apply -f argo-workflows/manifests/base/crds/minimal/
kubectl apply -f argo-events/manifests/base/crds/

# Await CRDs to be installed
echo "### Awaiting CRDs to be established..."
kubectl wait --for=condition=Established --timeout=15s crd workflows.argoproj.io
kubectl wait --for=condition=Established --timeout=15s crd cronworkflows.argoproj.io
kubectl wait --for=condition=Established --timeout=15s crd sensors.argoproj.io

# Remove artifacts
echo "### Removing artifacts..."
rm -rf argo-workflows/ \
  && rm -rf argo-events/

echo "### Finished."
