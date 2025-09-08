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

COPY su-exec.c /usr/local/bin/su-exec.c


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
FROM ${BASE_REGISTRY}/${BASE_IMAGE} AS build-env

ARG GOPROXY
ENV GOPROXY ${GOPROXY:-direct}

ARG GITEA_VERSION=release/v{{ $gitea.Version }}
ARG TAGS="sqlite sqlite_unlock_notify"
ENV TAGS "bindata timetzdata $TAGS"
ARG CGO_EXTRA_CFLAGS

RUN --mount=type=secret,id=credentials \
    set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        golang \
        nodejs \
        && rm -rf /var/lib/apt/lists/*


# Final image
FROM ${BASE_REGISTRY}/${BASE_IMAGE}

COPY --from=bootstrap /usr/src /usr/src

EXPOSE 22 3000

RUN --mount=type=secret,id=credentials \
    set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        git \
        gettext \
        openssh-server \
        s6 \
        sqlite3 \
        gnupg \
        && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/lib/x86_64-linux-musl/libc.so /lib/libc.musl-x86_64.so.1 \
    &&  ssh-keygen -A \
    && mkdir -p /run/sshd

COPY --from=bootstrap /usr/local/bin/su-exec.c /usr/local/bin/su-exec.c

# Install su-exec
RUN set -ex; \
    fetch_deps='gcc libc-dev'; \
    apt-get update; \
    apt-get install -y --no-install-recommends $fetch_deps; \
    rm -rf /var/lib/apt/lists/*; \
    gcc -Wall /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec; \
    chown root:root /usr/local/bin/su-exec; \
    chmod 0755 /usr/local/bin/su-exec; \
    apt-get purge -y --auto-remove $fetch_deps

RUN addgroup \
    --system --gid 1000 \
    git && \
    adduser \
    --system --no-create-home --disabled-password \
    --home /data/git \
    --shell /bin/bash \
    --uid 1000 \
    --gid 1000 \
    git && \
    echo "git:*" | chpasswd -e

ENV USER git
ENV GITEA_CUSTOM /data/gitea
ENV C2D_RELEASE 1.22.9

VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/usr/bin/s6-svscan", "/etc/s6"]