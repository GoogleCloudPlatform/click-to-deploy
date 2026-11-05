ARG BASE_REGISTRY="docker.io"
FROM marketplace.gcr.io/google/debian12@sha256:a5e684c8f4275ed6efedd7e5ea29d594b0e5d9d2ad9751f439b25824ae65d64c as downloader

ENV KUBE_STATE_METRICS_VERSION 2.15.0

RUN set -x && \
    apt-get update && \
    apt-get install -qq -y wget git && \
    git clone https://github.com/kubernetes/kube-state-metrics.git --branch v${KUBE_STATE_METRICS_VERSION} release

# Build the binary with Go
FROM docker.io/library/golang:1.26-bookworm as builder
WORKDIR /go/src/k8s.io/kube-state-metrics

ENV PKG=github.com/prometheus/common
ENV TAG=2.15.0

ENV GCO_ENABLED=0
ENV GOOS=linux

COPY --from=downloader release /go/src/k8s.io/kube-state-metrics

RUN set -x && \
    go get golang.org/x/crypto@v0.52.0 && \
    go mod tidy && \
    BuildDate="$(date -u +%Y-%m-%dT%H:%M:%SZ)" && \
    go build \
      -ldflags="-s -w -X ${PKG}/version.Version=${TAG} -X ${PKG}/version.BuildDate=${BuildDate} -X ${PKG}/version.BuildUser=C2D" \
      -o /kube-state-metrics

# Build the final image
FROM marketplace.gcr.io/google/debian12@sha256:a5e684c8f4275ed6efedd7e5ea29d594b0e5d9d2ad9751f439b25824ae65d64c

ENV C2D_RELEASE=2.15.0

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    apt-get install -y --only-upgrade libgnutls30 libpcre2-8-0 perl perl-base zlib1g && \
    rm -rf /var/lib/apt/lists/*

COPY --from=downloader /release/LICENSE /kube-state-metrics-LICENSE
COPY --from=builder /go/src/k8s.io/kube-state-metrics /usr/src/kube-state-metrics
COPY --from=builder /kube-state-metrics /

VOLUME /tmp
USER nobody

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT ["/kube-state-metrics", "--port=8080", "--telemetry-port=8081"]
