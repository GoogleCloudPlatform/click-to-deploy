# Copyright 2022 Google LLC
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

FROM node:12-alpine as console-builder

ARG MANAGER_CONSOLE_BRANCH=release-0.1.4
ARG CONSOLE_DIST=https://github.com/dragonflyoss/console/archive/refs/heads/${MANAGER_CONSOLE_BRANCH}.tar.gz

ADD ${CONSOLE_DIST} .

RUN tar -xvf $MANAGER_CONSOLE_BRANCH.tar.gz && \
    cd console-$MANAGER_CONSOLE_BRANCH && \
    npm install --loglevel warn --progress false && \
    npm run build


FROM golang:1.19-alpine3.16 as server-builder

ARG GOPROXY
ARG GOTAGS
ARG GOGCFLAGS
ARG DRAGONFLY2_GITHUB_BRANCH=release-2.0.8
ARG MANAGER_CONSOLE_BRANCH=release-0.1.4

WORKDIR /go/src/d7y.io/dragonfly/v2

RUN apk --no-cache add bash make gcc libc-dev git && \
    git clone -b ${DRAGONFLY2_GITHUB_BRANCH} https://github.com/dragonflyoss/Dragonfly2.git /go/src/d7y.io/dragonfly/v2 && \
    git clone -b ${MANAGER_CONSOLE_BRANCH} https://github.com/dragonflyoss/console.git /go/src/d7y.io/dragonfly/v2/manager/console

COPY --from=console-builder /console-$MANAGER_CONSOLE_BRANCH/dist /go/src/d7y.io/dragonfly/v2/manager/dist

RUN make build-manager-server && make install-manager

FROM marketplace.gcr.io/google/debian11 as health

ARG GRPC_HEALTH_PROBE_VERSION=v0.4.11

RUN apt update && apt install -y wget && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

FROM marketplace.gcr.io/google/debian11

WORKDIR /opt/dragonfly
ENV C2D_RELEASE 2.0.8
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

EXPOSE 8080 65003

ENTRYPOINT ["/docker-entrypoint.sh"]
