#!/bin/bash
#
# Copyright 2019 Google LLC
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

set -eox pipefail

# This is the entry point for the test deployment

overlay_test_schema.py \
    --orig "/data-test/schema.yaml" \
    --dest "/data/schema.yaml"
rm -f /data-test/schema.yaml

NAME="$(/bin/print_config.py \
    --xtype NAME \
    --values_mode raw)"
NAMESPACE="$(/bin/print_config.py \
    --xtype NAMESPACE \
    --values_mode raw)"
export NAME
export NAMESPACE

source common.sh

echo "Deploying application \"$NAME\" in test mode"

app_uid=$(kubectl get "applications/$NAME" \
    --namespace="$NAMESPACE" \
    --output=jsonpath='{.metadata.uid}')
app_api_version=$(kubectl get "applications/$NAME" \
    --namespace="$NAMESPACE" \
    --output=jsonpath='{.apiVersion}')

/bin/expand_config.py --values_mode raw --app_uid "$app_uid"

create_secret ${NAME} ${NAMESPACE}
patch_secret ${NAME} ${NAMESPACE}

create_manifests.sh --mode="test"

# Assign owner references for the resources.
/bin/set_ownership.py \
    --app_name "$NAME" \
    --app_uid "$app_uid" \
    --app_api_version "$app_api_version" \
    --manifests "/data/manifest-expanded" \
    --dest "/data/resources.yaml"

separate_tester_resources.py \
    --app_uid "$app_uid" \
    --app_name "$NAME" \
    --app_api_version "$app_api_version" \
    --manifests "/data/resources.yaml" \
    --out_manifests "/data/resources.yaml" \
    --out_test_manifests "/data/tester.yaml"

# Apply the manifest.
kubectl apply --namespace="$NAMESPACE" --filename="/data/resources.yaml"

patch_assembly_phase.sh --status="Success"

wait_for_ready.py \
    --name $NAME \
    --namespace $NAMESPACE \
    --timeout ${WAIT_FOR_READY_TIMEOUT:-300}

tester_manifest="/data/tester.yaml"
if [[ -e "$tester_manifest" ]]; then
    cat $tester_manifest

    run_tester.py \
        --namespace $NAMESPACE \
        --manifest $tester_manifest \
        --timeout ${TESTER_TIMEOUT:-300}
fi

/bin/clean_iam_resources.sh
