# Copyright 2024 Google LLC
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

FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl dnsutils netcat-traditional jq \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/kubectl/1.21 \
    && curl -L -o /opt/kubectl/1.21/kubectl \
       https://storage.googleapis.com/kubernetes-release/release/v1.21.6/bin/linux/amd64/kubectl \
    && chmod 755 /opt/kubectl/1.21/kubectl \
    && ln -s /opt/kubectl/1.21/kubectl /usr/bin/kubectl

COPY tests/spark-tests.yaml /tests/
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
