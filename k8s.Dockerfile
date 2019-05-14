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

FROM gcr.io/cloud-builders/gcloud

RUN set -eux \
    && apt-get update \
    && apt-get install python-pip -y \
    && pip install jinja2

# Get Docker CE for Ubuntu
# https://docs.docker.com/install/linux/docker-ce/ubuntu/
RUN set -eux \
    && apt-get install -y \
           apt-transport-https \
           ca-certificates \
           curl \
           gnupg-agent \
           software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && apt-key fingerprint 0EBFCD88 \
    && add-apt-repository \
          "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) \
          stable" \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io
