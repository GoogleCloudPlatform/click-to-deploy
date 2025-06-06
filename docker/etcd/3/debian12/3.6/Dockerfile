# Update and install necessary packages

FROM marketplace.gcr.io/google/debian12 as builder

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y wget git tar gzip build-essential

# Install Go
ARG GO_VERSION=1.20
RUN wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -xzf go${GO_VERSION}.linux-amd64.tar.gz -C /usr/local

# Configure environment variables for Go
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/go"
ENV PATH="$GOPATH/bin:$PATH"

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin"

# Install govendor
RUN go install github.com/kardianos/govendor@latest

# Configure environment variables for etcd
ARG ETCD_VERSION=3.6.0
ARG ETCD_SHA256=42305b0dcbba7b6fdff0382d0c7b99c42026c88c44847a619ab58cde216725d9
ENV ETCD_VER=${ETCD_VERSION}
ENV ETCD_FILE=etcd.tar.gz

# Download etcd source code and validate checksum
RUN wget -q https://github.com/etcd-io/etcd/releases/download/v${ETCD_VER}/etcd-v${ETCD_VER}-linux-amd64.tar.gz -O ${ETCD_FILE} && \
    echo "${ETCD_SHA256}  ${ETCD_FILE}" > checksum.txt && \
    sha256sum -c checksum.txt && \     
    mkdir -p $GOPATH/src/github.com/etcd-io/ && \
    tar -xzf ${ETCD_FILE} -C $GOPATH/src/github.com/etcd-io/ --strip-components=1

# List contents to debug
RUN ls -la $GOPATH/src/github.com/etcd-io/

# Generate licenses
RUN cd $GOPATH/src/github.com/etcd-io/ && \
    govendor license +vendor > /NOTICES

# Download etcd binaries
RUN wget -q https://github.com/etcd-io/etcd/releases/download/v${ETCD_VER}/etcd-v${ETCD_VER}-linux-amd64.tar.gz && \
    tar xzvf etcd-v${ETCD_VER}-linux-amd64.tar.gz -C /tmp && \
    mv /tmp/etcd-v${ETCD_VER}-linux-amd64/etcd /usr/local/bin/ && \
    mv /tmp/etcd-v${ETCD_VER}-linux-amd64/etcdctl /usr/local/bin/

# Download the release License
RUN wget -q https://raw.githubusercontent.com/etcd-io/etcd/v${ETCD_VER}/LICENSE -O /LICENSE

## Builded new "marketplace.gcr.io/google/debian12" container will contain only files copied from Builder image
FROM marketplace.gcr.io/google/debian12

ENV C2D_RELEASE=3.6.0 

RUN apt-get update && \
    apt-get install -y libc-bin libssl3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/etcd /usr/local/bin/etcdctl /usr/local/bin/
COPY --from=builder /LICENSE /usr/share/etcd/LICENSE
COPY --from=builder /NOTICES /usr/share/etcd/NOTICES
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV ETCD_DATA_DIR="/var/run/etcd/default.etcd"
EXPOSE 2379 2380

RUN etcd_version=$(etcd --version | grep 'etcd Version:' | cut -d ' ' -f 3) && \
    test "${C2D_RELEASE}" = "${etcd_version}" || { echo "Version check failed"; exit 1; }

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["etcd"]
