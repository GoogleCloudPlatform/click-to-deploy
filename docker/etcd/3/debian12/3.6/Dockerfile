# Update and install necessary packages

FROM marketplace.gcr.io/google/debian12 as builder

# Install build tools and wget
RUN apt-get update && \
    apt-get install -y wget tar gzip

# Install Go
ARG GO_VERSION=1.22.0
RUN wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -xzf go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local

ENV PATH="/usr/local/go/bin:$PATH"

# Set etcd version and checksum
ARG ETCD_VERSION=3.6.0
ARG ETCD_SHA256=42305b0dcbba7b6fdff0382d0c7b99c42026c88c44847a619ab58cde216725d9
ENV ETCD_VER=${ETCD_VERSION}
ENV ETCD_FILE=etcd.tar.gz

# Download and verify etcd
RUN wget -q https://github.com/etcd-io/etcd/releases/download/v${ETCD_VER}/etcd-v${ETCD_VER}-linux-amd64.tar.gz -O ${ETCD_FILE} && \
    echo "${ETCD_SHA256}  ${ETCD_FILE}" > checksum.txt && \
    sha256sum -c checksum.txt

# Extract etcd and etcdctl
RUN mkdir -p /tmp/etcd && \
    tar -xzf ${ETCD_FILE} -C /tmp/etcd --strip-components=1 && \
    mv /tmp/etcd/etcd /usr/local/bin/ && \
    mv /tmp/etcd/etcdctl /usr/local/bin/

# Copy LICENSE file
RUN wget -q https://raw.githubusercontent.com/etcd-io/etcd/v${ETCD_VER}/LICENSE -O /LICENSE

# -----------------------------
# Final production image
FROM marketplace.gcr.io/google/debian12

ENV C2D_RELEASE=3.6.0

RUN apt-get update && \
    apt-get install -y libc-bin libssl3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/etcd /usr/local/bin/
COPY --from=builder /usr/local/bin/etcdctl /usr/local/bin/
COPY --from=builder /LICENSE /usr/share/etcd/LICENSE
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV ETCD_DATA_DIR="/var/run/etcd/default.etcd"
EXPOSE 2379 2380

# Final check
RUN etcd_version=$(etcd --version | grep 'etcd Version:' | cut -d ' ' -f 3) && \
    test "${C2D_RELEASE}" = "${etcd_version}" || { echo "Version check failed"; exit 1; }

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["etcd"]
