# Copyright 2024 Google LLC
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

FROM golang:1.21-alpine as builder

ARG GOPROXY
ARG GOTAGS
ARG GOGCFLAGS

ARG DRAGONFLY2_GITHUB_BRANCH=v2.1.34
ARG MANAGER_CONSOLE_BRANCH=release-1.0.24

WORKDIR /go/src/d7y.io/dragonfly/v2

RUN apk --no-cache add bash make gcc libc-dev git && \
    git clone -b ${DRAGONFLY2_GITHUB_BRANCH} --recurse-submodules https://github.com/dragonflyoss/Dragonfly2.git /go/src/d7y.io/dragonfly/v2

RUN make build-dfget && make install-dfget

FROM marketplace.gcr.io/google/c2d-debian11 as health

ARG GRPC_HEALTH_PROBE_VERSION=v0.4.24

RUN apt update && apt install -y wget && \
    if [ "$(uname -m)" = "ppc64le" ]; then \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-ppc64le; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-arm64; \
    else \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64; \
    fi && \
    chmod +x /bin/grpc_health_probe

FROM marketplace.gcr.io/google/c2d-debian11
ENV C2D_RELEASE 2.1.34
ENV DRAGONFLY_MANAGER_ADDR localhost
ENV PATH=/opt/dragonfly/bin:$PATH

RUN echo "hosts: files dns" > /etc/nsswitch.conf

COPY --from=builder /opt/dragonfly/bin/dfget /opt/dragonfly/bin/dfget
COPY --from=health /bin/grpc_health_probe /bin/grpc_health_probe

COPY config/seed-peer.yaml /etc/dragonfly/dfget.yaml
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN apt update && apt install -y gettext-base && \
    chmod +x /docker-entrypoint.sh

EXPOSE 65001

ENTRYPOINT ["/docker-entrypoint.sh"]
