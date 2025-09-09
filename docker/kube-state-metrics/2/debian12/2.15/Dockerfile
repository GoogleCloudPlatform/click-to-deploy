# MOSS compliant images use a hardcoded registry and pinned base images.
ARG BASE_REGISTRY="marketplace.gcr.io/google"
ARG BASE_IMAGE="debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861"

# Stage 0: Airlock/Bootstrap
# This stage is for all external network operations, including fetching licenses,
# source code, and binaries from external sources.
FROM ${BASE_REGISTRY}/${BASE_IMAGE} AS bootstrap

RUN apt-get update && \
    apt-get install --no-install-recommends -y --allow-change-held-packages \
        gnupg curl ca-certificates apt-utils && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo 'deb http://packages.cloud.google.com/apt apt-transport-artifact-registry-stable main' | tee -a /etc/apt/sources.list.d/artifact-registry.list

RUN apt-get update && apt-get install apt-transport-artifact-registry

ENV KUBE_STATE_METRICS_VERSION 2.15.0

COPY kube-state-metrics-v${KUBE_STATE_METRICS_VERSION}.tar.gz /tmp/kube-state-metrics.tar.gz

RUN mkdir /release \
    && tar -xzf /tmp/kube-state-metrics.tar.gz -C /release --strip-components 1 \
    && rm /tmp/kube-state-metrics.tar.gz

# New clean base so we aren't fetching "gnupg curl apt-utils" if not needed
FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861 as base

# ca-certificates is required for https
RUN apt-get update && \
    apt-get install --no-install-recommends -y --allow-change-held-packages \
        ca-certificates

# Copy only the AR transport binary from the bootstrap stage
COPY --from=bootstrap "/usr/lib/apt/methods/ar+https" "/usr/lib/apt/methods/ar+https"
# Copy the apache notice type license for OSPO
COPY --from=bootstrap "/usr/share/doc/apt-transport-artifact-registry" "/usr/share/doc/apt-transport-artifact-registry"

# Remove all other apt sources
RUN rm -f /etc/apt/sources.list.d/* /etc/apt/sources.list

# This ARG allows passing credentials path during the build
ARG GOOGLE_APPLICATION_CREDENTIALS

# Use a secret mount to securely add the Airlock apt repository and update
RUN --mount=type=secret,id=credentials \
    echo 'deb ar+https://us-apt.pkg.dev/remote/artifact-foundry-prod/debian-3p-remote-bookworm bookworm main' | \
    tee -a  /etc/apt/sources.list.d/artifact-registry.list && \
    apt-get update

## Build Stage
FROM ${BASE_REGISTRY}/${BASE_IMAGE} AS builder

WORKDIR /go/src/k8s.io/kube-state-metrics

ENV PKG=github.com/prometheus/common
ENV TAG=2.15.0

ENV GCO_ENABLED=0
ENV GOOS=linux

COPY --from=bootstrap /release /go/src/k8s.io/kube-state-metrics

RUN --mount=type=secret,id=credentials \
    set -eux; \
    BuildDate="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Final image
FROM ${BASE_REGISTRY}/${BASE_IMAGE}

ENV C2D_RELEASE=2.15.0

COPY --from=bootstrap /release/LICENSE /kube-state-metrics-LICENSE

USER nobody

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT ["/usr/local/bin/kube-state-metrics", "--port=8080", "--telemetry-port=8081"]