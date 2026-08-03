# Update and install necessary packages

FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0 as builder

# Install basic build tools and wget
RUN apt-get update && \
    apt-get install -y wget tar gzip git ca-certificates

# Install Go
ARG GO_VERSION=1.25.9
RUN wget -q https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -xzf go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local

ENV PATH="/usr/local/go/bin:$PATH"

# Set etcd version
ARG ETCD_VERSION=3.5.33
ENV ETCD_VER=${ETCD_VERSION}

# Clone and compile etcd from source to resolve Go compiler format CVEs
RUN git clone --depth 1 -b v${ETCD_VER} https://github.com/etcd-io/etcd.git /usr/local/src/etcd && \
    cd /usr/local/src/etcd && \
    ( [ -f ./scripts/build.sh ] && ./scripts/build.sh || ./build.sh ) && \
    cp bin/etcd /usr/local/bin/ && \
    cp bin/etcdctl /usr/local/bin/ && \
    cp LICENSE /LICENSE

# ---------------------------------------
# Final lightweight image
FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

ENV C2D_RELEASE 3.5.33

RUN apt-get update && \
    apt-get install -y libc-bin libssl3 && \
    # Patch critical CVEs in base OS layer
    apt-get install -y --only-upgrade perl zlib1g && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/etcd /usr/local/bin/etcdctl /usr/local/bin/
COPY --from=builder /LICENSE /usr/share/etcd/LICENSE
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV ETCD_DATA_DIR="/var/run/etcd/default.etcd"
EXPOSE 2379 2380

# Validate etcd version
RUN etcd_version=$(etcd --version | grep 'etcd Version:' | cut -d ' ' -f 3) && \
    test "${C2D_RELEASE}" = "${etcd_version}" || { echo "Version check failed: expected ${C2D_RELEASE}, got ${etcd_version}"; exit 1; }

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["etcd"]
