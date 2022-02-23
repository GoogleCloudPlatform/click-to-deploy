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

case $AGENT_TYPE in
  ops-agent)
    export MAIN_CONFIG=file:///tmp/config/config.yaml
    ;;
  logging)
    export MAIN_CONFIG=file:///tmp/config/google-fluentd.conf
    export ADDITIONAL_CONFIG_DIR=/tmp/config/plugins/custom_config.conf
    ;;
  monitoring)
    export MAIN_CONFIG=file:///tmp/config/collectd.conf
    export ADDITIONAL_CONFIG_DIR=/tmp/config/plugins/example_plugin.conf
    ;;
  *)
    echo "AGENT_TYPE ${AGENT_TYPE} not supported"
    exit 1
    ;;
esac
