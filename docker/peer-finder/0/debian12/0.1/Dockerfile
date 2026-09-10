# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

ENV GOPATH /usr/local

RUN set -eux \
    && apt-get update \
    && apt-get install -y \
        wget \
        bash \
        dnsutils \
        curl \
        git \
    && apt-get install -y --only-upgrade perl zlib1g \
    && rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.25.13

# Download and Extract go binaries
RUN curl -o go.tar.gz https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz \
    && set -eux \
    && tar -C /usr/local -zxvf go.tar.gz

ADD peer-finder.go ${GOPATH}/src/peer-finder/peer-finder.go
ADD LICENSE ${GOPATH}/src/peer-finder/LICENSE

RUN set -eux \
    && cd "${GOPATH}/src/peer-finder" \
    && export GO111MODULE=on \
    && export PATH=$PATH:/usr/local/go/bin \
    && go mod init \
    && go get k8s.io/apimachinery/pkg/util/sets@v0.25.0 \
    && CGO_ENABLED=0 go build -o /peer-finder -a -installsuffix cgo --ldflags '-w' ./peer-finder.go \
    && rm -rf /usr/local/go /go.tar.gz ${GOPATH}/src/peer-finder

EXPOSE 9376
CMD ["/peer-finder"]
