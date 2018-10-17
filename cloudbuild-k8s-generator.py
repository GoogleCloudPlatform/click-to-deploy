#!/usr/bin/env python
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

import os

CLOUDBUILD_CONFIG = 'cloudbuild-k8s.yaml'

HEADER = """timeout: 1200s # 20m
options:
  machineType: 'N1_HIGHCPU_8'
steps:
"""

INITIALIZE_GIT = """
- id: Initialize Git
  name: gcr.io/cloud-builders/git
  entrypoint: bash
  args:
  - -exc
  - |
    # Download Git submodules
    git submodule init
    git submodule sync --recursive
    git submodule update --recursive --init
"""

GET_KUBERNETES_CREDENTIALS = """
- id: Get Kubernetes Credentials
  name: gcr.io/cloud-builders/gcloud
  args:
  - container
  - clusters
  - get-credentials
  - '$_CLUSTER_NAME'
  - --region
  - '$_CLUSTER_LOCATION'
  - --project
  - '$PROJECT_ID'
"""

SOLUTION_BUILD_STEP_TEMPLATE = """
- id: Verify <SOLUTION>
  name: gcr.io/cloud-marketplace-tools/k8s/dev:sha_3695cfc
  waitFor:
  - Initialize Git
  - Get Kubernetes Credentials
  dir: k8s/<SOLUTION>
  entrypoint: bash
  args:
  - -exc
  - |
    export KUBE_CONFIG=/workspace/.kube
    mkdir -p $$KUBE_CONFIG
    cp -r $$HOME/.kube/. $$KUBE_CONFIG
    cat $$KUBE_CONFIG/config

    export GCLOUD_CONFIG=/workspace/.config/gcloud
    mkdir -p $$GCLOUD_CONFIG
    cp -r $$HOME/.config/gcloud/. $$GCLOUD_CONFIG
    ls -al $$GCLOUD_CONFIG

    make -j4 app/verify
"""


def main():
  skiplist = ['vendor']

  cloudbuild_contents = ''.join(
      [HEADER, INITIALIZE_GIT, GET_KUBERNETES_CREDENTIALS])

  listdir = os.listdir('k8s')
  listdir.sort()

  for solution in listdir:
    if solution in skiplist:
      print('Skipping solution: ' + solution)
    else:
      print('Adding config for solution: ' + solution)
      # TODO(wgrzelak): Use python string format instead of replace.
      solution_build = SOLUTION_BUILD_STEP_TEMPLATE.replace(
          '<SOLUTION>', solution)
      cloudbuild_contents += solution_build

    # TODO(wgrzelak): Remove break.
    break

  with open(CLOUDBUILD_CONFIG, 'w') as cloudbuild_file:
    cloudbuild_file.write(cloudbuild_contents)


if __name__ == '__main__':
  main()
