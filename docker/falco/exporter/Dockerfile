FROM marketplace.gcr.io/google/debian12@sha256:f13f9826c524466f844e74534b8add32f51acd2be428b5dee782fe9086e59861

ENV EXPORTER_VERSION=0.8.7

RUN set -eu \
    # Installing utilities
    && apt-get update && apt-get install -y --no-install-recommends wget ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /opt/falco-exporter.tar.gz https://github.com/falcosecurity/falco-exporter/releases/download/v${EXPORTER_VERSION}/falco-exporter_${EXPORTER_VERSION}_linux_amd64.tar.gz \
    && tar xzf /opt/falco-exporter.tar.gz -C /opt/

EXPOSE 9376/tcp
EXPOSE 19376/tcp

ENTRYPOINT ["/opt/falco-exporter"]
