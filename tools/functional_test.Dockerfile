# Copyright 2025 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM gcr.io/cloud-builders/docker

ENV BAZEL_VERSION=0.19.2
ENV BAZEL_ARCH=linux_amd64_stripped

COPY ./ click-to-deploy/tools

RUN set -eux \
    && apt-get update \
    && apt-get install git wget unzip python g++ curl -y

# Install Bazel
RUN set -eux \
    && wget -q -O /bazel-installer.sh "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh" \
    && chmod +x /bazel-installer.sh \
    && /bazel-installer.sh \
    && bazel version

# Build the tools via Bazel.
WORKDIR /click-to-deploy/tools

RUN bazel build functional_test/src/runtest \
    && RUNTEST_PATH="$(realpath bazel-bin/functional_test/src/runtest/linux_amd64_stripped/runtest)" \
    && ln -s "${RUNTEST_PATH}" /runtest

ENTRYPOINT [ "/runtest" ]
