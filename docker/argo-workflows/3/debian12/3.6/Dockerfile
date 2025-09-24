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

COPY components.csv /components.csv
COPY source_code.txt /source_code.txt

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
    apt-get update && apt -y install ca-certificates curl && \
    chmod +x /download-licenses.sh && \
    chmod +x /download-ref-repos.sh && \
    mkdir -p /usr/src/licenses && \
    /download-licenses.sh /components.csv /usr/src/licenses && \
    /download-ref-repos.sh /source_code.txt /usr/src && \
    rm -rf /var/lib/apt/lists/*

# Stage: Server and Workflow Controller: Builder
FROM ${BASE_REGISTRY}/${BASE_IMAGE} AS builder

ARG ARGO_VERSION="3.6.7"
ENV ARGO_VERSION "${ARGO_VERSION}"

# Install build dependencies
RUN --mount=type=secret,id=credentials \
    set -eux; \
    apt-get update && apt-get --no-install-recommends install -y \
    git make apt-utils apt-transport-https ca-certificates wget gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man /usr/share/doc /usr/share/doc-base

WORKDIR /go/src/github.com/argoproj
WORKDIR /go/src/github.com/argoproj/argo-workflows

# Stage: Server: UI
FROM ${BASE_REGISTRY}/${BASE_IMAGE} AS argo-ui

RUN JOBS=max yarn --cwd ui install --network-timeout 1000000

RUN NODE_OPTIONS="--max-old-space-size=2048" JOBS=max yarn --cwd ui build

# Stage: Workflow Controller: Build
FROM builder as workflow-controller-build

# Tell git to forget about all of the files that were not included because of .dockerignore in order to ensure that
# the git state is "clean" even though said .dockerignore files are not present
RUN cat .dockerignore >> .gitignore
RUN git status --porcelain | cut -c4- | xargs git update-index --skip-worktree

RUN target=/root/.cache/go-build make dist/workflow-controller

# Stage: ArgoCLI
FROM builder as argocli-build

RUN mkdir -p ui/dist
COPY --from=argo-ui ui/dist/app ui/dist/app
# stop make from trying to re-build this without yarn installed
RUN touch ui/dist/node_modules.marker
RUN touch ui/dist/app/index.html

# Tell git to forget about all of the files that were not included because of .dockerignore in order to ensure that
# the git state is "clean" even though said .dockerignore files are not present
RUN cat .dockerignore >> .gitignore
RUN git status --porcelain | cut -c4- | xargs git update-index --skip-worktree

RUN target=/root/.cache/go-build make dist/argo

# Stage: Final Image
FROM ${BASE_REGISTRY}/${BASE_IMAGE}

COPY --from=bootstrap /usr/src /usr/src

ENV C2D_RELEASE "3.6.7"
USER 8737

COPY docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
