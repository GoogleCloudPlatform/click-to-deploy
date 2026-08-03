ARG BASE_REGISTRY="docker.io"
FROM docker.io/golang as exporter-builder

ENV GOPATH /usr/local

ENV EXPORTER_VERSION 0.19.0
ENV EXPORTER_SHA256 97238be558bd1a6aa6b9a927fa21d91dc5cabe6b9e00678b5cafa2bbb3899e72

# Installs packages
RUN set -eux \
    && apt-get update \
    && apt-get install -y \
        curl \
        tar

RUN set -eux \
    # Downloads binary
    && curl -L -O "https://github.com/prometheus/mysqld_exporter/releases/download/v${EXPORTER_VERSION}/mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" \
    # Verifies checksum
    && echo "${EXPORTER_SHA256} mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" | sha256sum -c \
    # Untar binary
    && tar -xzf "mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" --strip-components=1 \
    && rm "mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" \
    && rm NOTICE

RUN set -eux \
    # Downloads source code
    && curl -L -o /tmp/mysqld_exporter.tar.gz "https://github.com/prometheus/mysqld_exporter/archive/v${EXPORTER_VERSION}.tar.gz" \
    && mkdir -p "${GOPATH}/src/github.com/prometheus/mysqld_exporter" \
    && tar -xzf /tmp/mysqld_exporter.tar.gz --strip-components=1 -C "${GOPATH}/src/github.com/prometheus/mysqld_exporter"

FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

#resolve security issues
RUN apt-get update; \
  	apt-get install -y --no-install-recommends libtasn1-6; \
    apt-get install -y --only-upgrade perl zlib1g; \
  	rm -rf /var/lib/apt/lists/*

COPY --from=exporter-builder /go/mysqld_exporter /bin/mysqld_exporter
COPY --from=exporter-builder /go/LICENSE /usr/share/mysqld_exporter/LICENSE
COPY --from=exporter-builder /usr/local/src/github.com/prometheus/mysqld_exporter /usr/local/src/mysqld_exporter

EXPOSE 9104
ENTRYPOINT ["/bin/mysqld_exporter"]
