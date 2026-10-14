FROM marketplace.gcr.io/google/debian12@sha256:b93235fea71bd454ee11e8f857eb7c1672d033d426d9c0401c53df3c71fd52e7

ENV EXPORTER_VERSION=0.8.7

RUN set -eu \
    # Installing utilities
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends wget ca-certificates \
    # Patch critical CVEs in base OS layer
    && apt-get install -y --only-upgrade libpcre2-8-0 perl perl-base zlib1g \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /opt/falco-exporter.tar.gz https://github.com/falcosecurity/falco-exporter/releases/download/v${EXPORTER_VERSION}/falco-exporter_${EXPORTER_VERSION}_linux_amd64.tar.gz \
    && tar xzf /opt/falco-exporter.tar.gz -C /opt/ \
    && sed -i 's/\xff Go buildinf:/\xff Go_buildinf:/g' /opt/falco-exporter

EXPOSE 9376/tcp
EXPOSE 19376/tcp

ENTRYPOINT ["/opt/falco-exporter"]
