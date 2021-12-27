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

FROM marketplace.gcr.io/google/debian9 AS build

ENV BAZEL_VERSION 0.19.2
ENV BAZEL_ARCH linux_amd64_stripped

RUN set -eux \
    && apt-get update \
    && apt-get install git wget unzip python g++ -y

# Install Bazel
RUN set -eux \
    && wget -q -O /bazel-installer.sh "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh" \
    && chmod +x /bazel-installer.sh \
    && /bazel-installer.sh

RUN set -eux \
    && git clone https://github.com/GoogleCloudPlatform/runtimes-common.git --depth=1 \
    && cd runtimes-common \
    && bazel run //:gazelle \
    && bazel build versioning/scripts/dockerfiles:dockerfiles versioning/scripts/cloudbuild:cloudbuild \
    && cp bazel-bin/versioning/scripts/dockerfiles/${BAZEL_ARCH}/dockerfiles /bin/dockerfiles \
    && cp bazel-bin/versioning/scripts/cloudbuild/${BAZEL_ARCH}/cloudbuild /bin/cloudbuild

FROM marketplace.gcr.io/google/debian9

COPY --from=build /bin/dockerfiles /bin/dockerfiles
COPY --from=build /bin/cloudbuild /bin/cloudbuild
