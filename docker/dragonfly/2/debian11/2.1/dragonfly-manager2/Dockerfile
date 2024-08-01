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

FROM marketplace.gcr.io/google/c2d-debian11 as ospo

# Download Licenses and restricted source-code
COPY components.csv /components.csv
COPY source_code.txt /source_code.txt

RUN apt update && apt -y install ca-certificates

RUN curl -o /download-licenses.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-licenses.sh \
		&& curl -o /download-ref-repos.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-ref-repos.sh \
		&& chmod +x /download-licenses.sh \
		&& chmod +x /download-ref-repos.sh

RUN mkdir -p /usr/src/licenses \
		&& /download-licenses.sh /components.csv /usr/src/licenses \
		&& /download-ref-repos.sh /source_code.txt /usr/src

FROM node:20-alpine as console-builder

ARG MANAGER_CONSOLE_BRANCH=release-1.0.24
ARG MANAGER_CONSOLE_TAR=v1.0.24
ARG CONSOLE_DIST=https://github.com/dragonflyoss/console/archive/refs/tags/${MANAGER_CONSOLE_TAR}.tar.gz

ADD ${CONSOLE_DIST} .

RUN tar -xvf $MANAGER_CONSOLE_TAR.tar.gz && \
    cd console-1.0.24 && \
    npm install -g npm@10.5.0 && \
    npm install --legacy-peer-deps --loglevel warn --progress false && \
    npm run build


FROM golang:1.21-alpine as server-builder

ARG GOPROXY
ARG GOTAGS
ARG GOGCFLAGS
ARG DRAGONFLY2_GITHUB_BRANCH=v2.1.34
ARG MANAGER_CONSOLE_BRANCH=release-1.0.24

WORKDIR /go/src/d7y.io/dragonfly/v2

RUN apk --no-cache add bash make gcc libc-dev git && \
    git clone -b ${DRAGONFLY2_GITHUB_BRANCH} --recurse-submodules https://github.com/dragonflyoss/Dragonfly2.git /go/src/d7y.io/dragonfly/v2

COPY --from=console-builder /console-1.0.24/dist /go/src/d7y.io/dragonfly/v2/manager/dist

RUN make build-manager-server && make install-manager

FROM marketplace.gcr.io/google/c2d-debian11 as health

ARG GRPC_HEALTH_PROBE_VERSION=v0.4.24

RUN apt update && apt install -y wget && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

FROM marketplace.gcr.io/google/c2d-debian11

WORKDIR /opt/dragonfly
ENV C2D_RELEASE 2.1.34
ENV PATH=/opt/dragonfly/bin:$PATH
ENV DRAGONFLY_MANAGER_ADDR localhost
ENV DRAGONFLY_MYSQL_USER dragonfly
ENV DRAGONFLY_MYSQL_PW dragonfly
ENV DRAGONFLY_MYSQL_DBNAME manager
ENV DRAGONFLY_MYSQL_HOST localhost
ENV DRAGONFLY_REDIS_PW dragonfly
ENV DRAGONFLY_REDIS_HOST localhost


RUN mkdir -p /opt/dragonfly/bin/manager/console &&\
    echo "hosts: files dns" > /etc/nsswitch.conf

COPY --from=server-builder /opt/dragonfly/bin/manager /opt/dragonfly/bin/server
COPY --from=health /bin/grpc_health_probe /bin/grpc_health_probe
COPY config/manager.yaml /etc/dragonfly/manager.yaml
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN apt update && apt install -y curl gettext-base && \
    chmod +x /docker-entrypoint.sh

COPY --from=ospo /usr/src /usr/src

EXPOSE 8080 65003

ENTRYPOINT ["/docker-entrypoint.sh"]
