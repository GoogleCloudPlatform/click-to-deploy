FROM marketplace.gcr.io/google/debian12 as builder

ENV GOPATH /usr/local

ENV EXPORTER_VERSION 0.12.1
ENV EXPORTER_SHA256 ea385176714dc6692c44ccedeb3c23f66d410a4820ae51179a62db9de56eb54d

ENV NOTICES_SHA256 01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b

# Installs packages
RUN set -eux \
    && apt-get update \
    && apt-get install -y \
        curl \
        golang \
        tar

RUN go install github.com/kardianos/govendor@latest

RUN set -eux \
    # Downloads binary
    && curl -L -O "https://github.com/prometheus/consul_exporter/releases/download/v${EXPORTER_VERSION}/consul_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" \
    # Verifies checksum
    && echo "${EXPORTER_SHA256} consul_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" | sha256sum -c \
    # Untar binary
    && tar -xzf "consul_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" --strip-components=1 \
    && rm "consul_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" \
    && rm NOTICE

RUN set -eux \
    # Downloads source code
    && curl -L -o /tmp/consul_exporter.tar.gz "https://github.com/prometheus/consul_exporter/archive/v${EXPORTER_VERSION}.tar.gz" \
    && mkdir -p "${GOPATH}/src/github.com/prometheus/consul_exporter" \
    && tar -xzf /tmp/consul_exporter.tar.gz --strip-components=1 -C "${GOPATH}/src/github.com/prometheus/consul_exporter"

RUN set -eux \
    # Extracts licences
    && cd "${GOPATH}/src/github.com/prometheus/consul_exporter" \
    && govendor license +vendor > /NOTICES \
    # Verifies checksum. Changing the checksum means changing the licenses.
    && echo "${NOTICES_SHA256} /NOTICES" | sha256sum -c \
    && cp -R "${GOPATH}/src/github.com/prometheus/consul_exporter" /tmp/


FROM marketplace.gcr.io/google/debian12
# The scratch image is the most minimal image in Docker. It doesn't contain any folders/files.
# Builded container will be contain only files copied downstair.

COPY --from=builder /consul_exporter /bin/consul_exporter
COPY --from=builder /LICENSE /usr/share/consul_exporter/LICENSE
COPY --from=builder /NOTICES /usr/share/consul_exporter/NOTICES
COPY --from=builder /tmp/consul_exporter /usr/local/src/consul_exporter

EXPOSE 9107
ENTRYPOINT ["/bin/consul_exporter"]
