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

FROM marketplace.gcr.io/google/debian11

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
    && /bazel-installer.sh

# Install gh CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh

RUN set -eux \
    && cd click-to-deploy/tools \
    && bazel build dockerversioning/scripts/dockerfiles:dockerfiles dockerversioning/scripts/cloudbuild:cloudbuild \
    && cp bazel-bin/dockerversioning/scripts/dockerfiles/${BAZEL_ARCH}/dockerfiles /bin/dockerfiles \
    && cp bazel-bin/dockerversioning/scripts/cloudbuild/${BAZEL_ARCH}/cloudbuild /bin/cloudbuild
