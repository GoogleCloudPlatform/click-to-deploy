FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0 as exporter-builder

ENV GOPATH /usr/local
ENV GOROOT /usr/local/go
ENV GO_VERSION 1.25.9
ENV PATH=${GOPATH}/bin:${GOROOT}/bin:${PATH}
ENV EXPORTER_VERSION 0.13.4

# Installs packages
RUN set -eux \
    && apt-get update \
    && apt-get install -y \
        curl \
        tar \
        git \
        make \
        gcc

# Installs golang version ${GO_VERSION}
RUN set -eux \
    && curl -L -o /tmp/go${GO_VERSION}.linux-amd64.tar.gz "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" \
    && tar -xzf /tmp/go${GO_VERSION}.linux-amd64.tar.gz -C ${GOPATH}

RUN set -eux \
    # Downloads source code
    && curl -L -o /tmp/apache_exporter.tar.gz "https://github.com/Lusitaniae/apache_exporter/archive/v${EXPORTER_VERSION}.tar.gz" \
    && mkdir -p /usr/local/src/apache_exporter \
    && tar -xzf /tmp/apache_exporter.tar.gz --strip-components=1 -C /usr/local/src/apache_exporter

RUN set -eux \
    && go install github.com/kardianos/govendor@latest \
    && mkdir -p "${GOPATH}/src/github.com/Lusitaniae/apache_exporter" \
    && cd "${GOPATH}/src/github.com/Lusitaniae/apache_exporter" \
    && tar -xzf /tmp/apache_exporter.tar.gz --strip-components=1 -C . \
    # Initialize Go module to bypass local legacy vendor directory
    && go mod init github.com/Lusitaniae/apache_exporter || true \
    && go get golang.org/x/crypto@latest \
    && go mod tidy \
    && go build -ldflags "-s -w" -o /apache_exporter \
    # Extracts licences
    && (govendor license +vendor > /NOTICES || cp LICENSE /NOTICES)

FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

# Update libtasn
RUN apt-get update \
    && apt-get install --no-install-recommends -yqq libtasn1-6 \
    # Patch critical CVEs in base OS layer
    && apt-get install -y --only-upgrade perl zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=exporter-builder /apache_exporter /bin/apache_exporter
COPY --from=exporter-builder /NOTICES /usr/share/apache_exporter/NOTICES
COPY --from=exporter-builder /usr/local/src/apache_exporter /usr/local/src/apache_exporter

EXPOSE 9117
ENTRYPOINT ["/bin/apache_exporter"]
