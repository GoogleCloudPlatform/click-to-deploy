#!/usr/bin/env bash

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script validates environment variables and configures
# required environment variables

set -e

if [ -z "$AGENT_TYPE" ]; then
    echo "AGENT_TYPE not set"
    exit 1
fi

if [ -z "$CHEF_CONFIG_BASE" ]; then
    echo "CHEF_CONFIG_BASE not set"
    exit 1
fi

if [ -z "$CHEF_GCP_PROJECT" ]; then
    echo "CHEF_GCP_PROJECT not set"
    exit 1
fi

if [ -z "$CHEF_GCP_ZONE" ]; then
    echo "CHEF_GCP_ZONE not set"
    exit 1
fi

if [ -z "$CHEF_SSH_KEY" ]; then
    echo "CHEF_SSH_KEY not set"
    exit 1
fi

if [ -z "$CHEF_SSH_USER" ]; then
    echo "CHEF_SSH_USER not set"
    exit 1
fi

INSTANCE=$(kitchen list | grep GCE | awk '{print $1}')
GCE_INSTANCE=$(grep server_name "./.kitchen/${INSTANCE}.yml" | awk '{print $2}')

kitchen exec "${INSTANCE}" -c "mkdir -p /tmp/config/plugins"

case $AGENT_TYPE in
  ops-agent)
    gcloud --project "${CHEF_GCP_PROJECT}" compute scp \
      "${CHEF_CONFIG_BASE}/config.yaml" \
      "${CHEF_SSH_USER}@${GCE_INSTANCE}:/tmp/config/config.yaml" \
      --zone "${CHEF_GCP_ZONE}" \
      --ssh-key-file "${CHEF_SSH_KEY}"
    ;;
  logging)
    gcloud --project "${CHEF_GCP_PROJECT}" compute scp \
      "${CHEF_CONFIG_BASE}/google-fluentd.conf" \
      "${CHEF_SSH_USER}@${GCE_INSTANCE}:/tmp/config/google-fluentd.conf" \
      --zone "${CHEF_GCP_ZONE}" \
      --ssh-key-file "${CHEF_SSH_KEY}"
    gcloud --project "${CHEF_GCP_PROJECT}" compute scp \
      "${CHEF_CONFIG_BASE}/plugins/custom_config.conf" \
      "${CHEF_SSH_USER}@${GCE_INSTANCE}:/tmp/config/plugins/custom_config.conf" \
      --zone "${CHEF_GCP_ZONE}" \
      --ssh-key-file "${CHEF_SSH_KEY}"
    ;;
  monitoring)
    gcloud --project "${CHEF_GCP_PROJECT}" compute scp \
      "${CHEF_CONFIG_BASE}/collectd.conf" \
      "${CHEF_SSH_USER}@${GCE_INSTANCE}:/tmp/config/collectd.conf" \
      --zone "${CHEF_GCP_ZONE}" \
      --ssh-key-file "${CHEF_SSH_KEY}"
    gcloud --project "${CHEF_GCP_PROJECT}" compute scp \
      "${CHEF_CONFIG_BASE}/plugins/example_plugin.conf" \
      "${CHEF_SSH_USER}@${GCE_INSTANCE}:/tmp/config/plugins/example_plugin.conf" \
      --zone "${CHEF_GCP_ZONE}" \
      --ssh-key-file "${CHEF_SSH_KEY}"
    ;;
  *)
    echo "AGENT_TYPE ${AGENT_TYPE} not supported"
    exit 1
    ;;
esac
