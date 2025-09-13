# Download and unpack the Kube State Merics release code from github
FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861 as downloader

ENV KUBE_STATE_METRICS_VERSION 2.15.0

RUN set -x && \
    apt-get update && \
    apt-get install -qq -y wget git && \
    git clone https://github.com/kubernetes/kube-state-metrics.git --branch v${KUBE_STATE_METRICS_VERSION} release

# Build the binary with Go
FROM docker.io/golang as builder
WORKDIR /go/src/k8s.io/kube-state-metrics

ENV PKG=github.com/prometheus/common
ENV TAG=2.15.0

ENV GCO_ENABLED=0
ENV GOOS=linux

COPY --from=downloader release /go/src/k8s.io/kube-state-metrics

RUN set -x && \
    BuildDate="$(date -u +%Y-%m-%dT%H:%M:%SZ)" && \
    go build \
      -ldflags="-s -w -X ${PKG}/version.Version=${TAG} -X ${PKG}/version.BuildDate=${BuildDate} -X ${PKG}/version.BuildUser=C2D" \
      -o kube-state-metrics

# Build the final image
FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861

ENV C2D_RELEASE=2.15.0

COPY --from=downloader /release/LICENSE /kube-state-metrics-LICENSE
COPY --from=downloader /release /usr/src/kube-state-metrics
COPY --from=builder /go/src/k8s.io/kube-state-metrics/kube-state-metrics /

VOLUME /tmp
USER nobody

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT ["/kube-state-metrics", "--port=8080", "--telemetry-port=8081"]
