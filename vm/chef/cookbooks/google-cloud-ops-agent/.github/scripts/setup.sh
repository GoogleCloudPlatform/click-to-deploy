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

set -e

# handle ssh key
mkdir -p ~/.ssh
echo "$CHEF_PRIVATE_KEY" > ~/.ssh/id_rsa
echo "$CHEF_PUBLIC_KEY" > ~/.ssh/id_rsa.pub
chmod 0600 ~/.ssh/*

# install workstation + test kitchen + inspec
curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -P cinc-workstation -v 21 -c unstable
