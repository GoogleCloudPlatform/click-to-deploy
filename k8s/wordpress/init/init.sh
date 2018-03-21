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

if [ -z "$AGENT_LOCAL_PORT" ]; then
  echo "AGENT_LOCAL_PORT environment variable must be set"
  exit 1
fi

if [ ! -d "/var/www/html" ]; then
  echo "/var/www/html directory must be mounted"
  exit 1
fi

if [ ! -d "/etc/ubbagent" ]; then
  echo "/etc/ubbagent directory must be mounted"
  exit 1
fi

# Expand and copy Wordpress metering plugin.
mkdir -p /var/www/html/wp-content/mu-plugins
sed "s/%%AGENT_LOCAL_PORT%%/$AGENT_LOCAL_PORT/g" /metering.php.tmpl > /var/www/html/wp-content/mu-plugins/metering.php

# Copy the metering agent config.
cp /agent-config.yaml /etc/ubbagent/config.yaml
