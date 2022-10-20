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

RUN make build-scheduler && make install-scheduler

FROM marketplace.gcr.io/google/debian11 as health

ARG GRPC_HEALTH_PROBE_VERSION=v0.4.11

RUN apt update && apt install -y wget && \
    wget -qO/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 && \
    chmod +x /bin/grpc_health_probe

FROM marketplace.gcr.io/google/debian11

ENV DRAGONFLY_REDIS_PW dragonfly
ENV DRAGONFLY_REDIS_HOST localhost
ENV DRAGONFLY_MANAGER_ADDR localhost

ENV PATH=/opt/dragonfly/bin:$PATH
RUN echo "hosts: files dns" > /etc/nsswitch.conf

COPY --from=builder /opt/dragonfly/bin/scheduler /opt/dragonfly/bin/scheduler
COPY --from=health /bin/grpc_health_probe /bin/grpc_health_probe

COPY config/scheduler.yaml /etc/dragonfly/scheduler.yaml
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN apt update && apt install -y gettext-base && \
    chmod +x /docker-entrypoint.sh 

EXPOSE 8002

ENTRYPOINT ["/docker-entrypoint.sh"]