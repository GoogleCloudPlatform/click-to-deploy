#!/bin/bash
#
# Copyright 2018 Google LLC
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

set -e
set -o pipefail
set -x

# Assert existence of required environment variables.
[[ -v "APP_INSTANCE_NAME" ]] || exit 1
[[ -v "NAMESPACE" ]] || exit 1

# Generates a random string of a specified length and return its Base-64 encoded version.
function generate_password_base64() {
  local length="$1"
  < /dev/urandom tr -dc 'A-Za-z0-9' | head -c"$length" | base64
  return 0
}

# Evaluate password expression passed as the first and only parameter.
function evaluate_password_expression() {
  local pwd_expr="$1"
  local length=10
  if [[ "$pwd_expr" =~ .*length=[\s]*[0-9]+[\s]*.* ]]; then
    length="$(echo "$pwd_expr" | sed -n 's/.*length=\([0-9]*\).*/\1/p')"
  fi
  generate_password_base64 "$length"
}

# Replace all occurrences of password-generation expressions
# in-place in a file specified as the first parameter.
# Valid password expression:
# - is specified in a single line,
# - starts and ends with '%%',
# - uses a function-like name - generate_password_base64, followed by the list of parameters,
# - optionally specifies a parameter of password's length - 'length=<number>'.
#
# Sample valid password expressions:
# - %% generated_password_base64() %%,
# - %% generated_password_base64(length = 12) %%.
function replace_password_expressions_inplace() {
  local filename="$1"

  local pwd_expressions
  local pwd_expression

  IFS=$'\n' pwd_expressions=( $(sed -n 's/.*\(%%.*generate_password_base64(.*).*%%\).*/\1/p' \
    "$filename") )

  for pwd_expression in "${pwd_expressions[@]}"; do
    generated_value="$(evaluate_password_expression "$pwd_expression")"
    echo "print the file from $filename"
    cat "$filename"
    sed "0,/$pwd_expression/{s/$pwd_expression/$generated_value/}" "$filename"
    echo "now replacing contents of $filename..."
    sed -i "0,/$pwd_expression/{s/$pwd_expression/$generated_value/}" "$filename"
  done
}

# Assign owner references to the existing kubernates resources tagged with the application name
APPLICATION_UID=$(kubectl get "applications/$APP_INSTANCE_NAME" \
  --namespace="$NAMESPACE" \
  --output=jsonpath='{.metadata.uid}')

top_level_kinds=$(kubectl get "applications/$APP_INSTANCE_NAME" \
  --namespace="$NAMESPACE" \
  --output=json \
  | jq -r '.spec.componentKinds[] | .kind')

top_level_resources=()
for kind in ${top_level_kinds[@]}; do
  top_level_resources+=($(kubectl get "$kind" \
    --selector app.kubernetes.io/name="$APP_INSTANCE_NAME" \
    --output=json \
    | jq -r '.items[] | [.kind, .metadata.name] | join("/")'))
done

for resource in ${top_level_resources[@]}; do
  kubectl patch "$resource" \
    --namespace="$NAMESPACE" \
    --type=merge \
    --patch="metadata:
               ownerReferences:
               - apiVersion: extensions/v1beta1
                 blockOwnerDeletion: true
                 controller: true
                 kind: Application
                 name: $APP_INSTANCE_NAME
                 uid: $APPLICATION_UID" || true
done

# Perform environment variable expansions.
# Note: We list out all environment variables and explicitly pass them to
# envsubst to avoid expanding templated variables that were not defined
# in this container.
environment_variables="$(printenv \
  | sed 's/=.*$//' \
  | sed 's/^/$/' \
  | paste -d' ' -s)"

data_dir="/data"
manifest_dir="$data_dir/manifest-expanded"
mkdir "$manifest_dir"

# Replace the environment variables placeholders from the manifest templates
for manifest_template_file in "$data_dir"/manifest/*; do
  manifest_file=$(basename "$manifest_template_file" | sed 's/.template$//')

  cat "$manifest_template_file" \
    | envsubst "$environment_variables" \
    > "$manifest_dir/$manifest_file"
  replace_password_expressions_inplace "$manifest_dir/$manifest_file"
done

# Set Application to own all resources defined in its component kinds.
# by inserting ownerReference in manifest before applying.''
resources_yaml="$data_dir/resources.yaml"
python /bin/setownership.py \
  --appname "$APP_INSTANCE_NAME" \
  --appuid "$APPLICATION_UID" \
  --manifests "$manifest_dir" \
  --dest "$resources_yaml"

# Apply the manifest.
kubectl apply --namespace="$NAMESPACE" --filename="$resources_yaml"

kubectl patch "applications/$APP_INSTANCE_NAME" \
  --namespace="$NAMESPACE" \
  --type=merge \
  --patch "metadata:
             annotations:
               kubernetes-engine.cloud.google.com/application-deploy-status: Succeeded"
