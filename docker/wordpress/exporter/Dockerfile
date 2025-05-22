FROM marketplace.gcr.io/google/debian12 as exporter-builder

ENV GOPATH /usr/local
ENV GOROOT /usr/local/go
ENV GO_VERSION 1.20
ENV PATH=${GOPATH}/bin:${GOROOT}/bin:${PATH}
ENV EXPORTER_VERSION 0.13.4

# Installs packages
RUN set -eux \
    && apt-get update \
    && apt-get install -y \
        curl \
        govendor \
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
    && mkdir -p "${GOPATH}/src/github.com/Lusitaniae/apache_exporter" \
    && cd "${GOPATH}/src/github.com/Lusitaniae/apache_exporter" \
    && tar -xzf /tmp/apache_exporter.tar.gz --strip-components=1 -C . \
    # Download binary
    && curl -L -o /tmp/apache_exporter-${EXPORTER_VERSION} "https://github.com/Lusitaniae/apache_exporter/releases/download/v${EXPORTER_VERSION}/apache_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" \
    && tar -xzf /tmp/apache_exporter-${EXPORTER_VERSION} --strip-components=1 -C . \
    && mv apache_exporter /apache_exporter \
    # Extracts licences
    && govendor license +vendor > /NOTICES

FROM marketplace.gcr.io/google/debian12

# Update libtasn
RUN apt-get update \
    && apt-get install --no-install-recommends -yqq libtasn1-6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=exporter-builder /apache_exporter /bin/apache_exporter
COPY --from=exporter-builder /NOTICES /usr/share/apache_exporter/NOTICES
COPY --from=exporter-builder /usr/local/src/apache_exporter /usr/local/src/apache_exporter

EXPOSE 9117
ENTRYPOINT ["/bin/apache_exporter"]
