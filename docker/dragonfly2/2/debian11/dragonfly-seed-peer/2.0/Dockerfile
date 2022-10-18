FROM golang:1.18.3-alpine3.16 as builder

ARG GOPROXY
ARG GOTAGS
ARG GOGCFLAGS

ARG DRAGONFLY2_GITHUB_BRANCH=release-2.0.6
ARG MANAGER_CONSOLE_BRANCH=release-0.1.4

WORKDIR /go/src/d7y.io/dragonfly/v2

RUN apk --no-cache add bash make gcc libc-dev git && \
    git clone -b ${DRAGONFLY2_GITHUB_BRANCH} https://github.com/dragonflyoss/Dragonfly2.git /go/src/d7y.io/dragonfly/v2 && \
    git clone -b ${MANAGER_CONSOLE_BRANCH} https://github.com/dragonflyoss/console.git /go/src/d7y.io/dragonfly/v2/manager/console

RUN make build-dfget && make install-dfget

FROM marketplace.gcr.io/google/debian11 as health

ARG GRPC_HEALTH_PROBE_VERSION=v0.4.11

RUN apt update && apt install -y wget && \
    if [ "$(uname -m)" = "ppc64le" ]; then \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-ppc64le; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-arm64; \
    else \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64; \
    fi && \
    chmod +x /bin/grpc_health_probe

FROM marketplace.gcr.io/google/debian11

ENV DRAGONFLY_MANAGER_ADDR localhost
ENV DRAGONFLY_SCHEDULER_ADDR localhost

ENV PATH=/opt/dragonfly/bin:$PATH
RUN echo "hosts: files dns" > /etc/nsswitch.conf

COPY --from=builder /opt/dragonfly/bin/dfget /opt/dragonfly/bin/dfget
COPY --from=health /bin/grpc_health_probe /bin/grpc_health_probe

COPY config/seed-peer.yaml /etc/dragonfly/dfget.yaml
EXPOSE 65001

ENTRYPOINT ["/opt/dragonfly/bin/dfget", "daemon"]