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

set -eo pipefail

chmod 600 /root/.ssh/googlecloudplatform_marketplace-k8s-app-tools
chmod 600 /root/.ssh/googlecloudplatform_ubbagent

# Configuring one ssh key for each submodule to be pull.
# Github does not support role based access over ssh. Therefore we use deploy keys.
# Github does not allow a deploy key to be shared between repositories.
# so we have to keep one deploy key per repo and configure ssh to pick
# the correct one.

ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts

ssh-agent bash -c "ssh-add -D; ssh-add /root/.ssh/googlecloudplatform_marketplace-k8s-app-tools; git submodule init; git submodule update k8s/vendor/marketplace-tools"

cd k8s/vendor/marketplace-tools
ssh-agent bash -c "ssh-add -D; ssh-add /root/.ssh/googlecloudplatform_ubbagent; git submodule init; git submodule update vendor/ubbagent"
