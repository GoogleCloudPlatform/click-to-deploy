FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

ENV EXPORTER_VERSION=0.8.7

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends wget ca-certificates \
    # Patch critical CVEs in base OS layer
    && apt-get install -y --only-upgrade perl zlib1g \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /opt/falco-exporter.tar.gz https://github.com/falcosecurity/falco-exporter/releases/download/v${EXPORTER_VERSION}/falco-exporter_${EXPORTER_VERSION}_linux_amd64.tar.gz \
    && tar xzf /opt/falco-exporter.tar.gz -C /opt/

EXPOSE 9376/tcp
EXPOSE 19376/tcp

ENTRYPOINT ["/opt/falco-exporter"]
