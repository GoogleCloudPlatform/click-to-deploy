FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

ARG EXPORTER_VERSION=0.20.1
ENV EXPORTER_VERSION "${EXPORTER_VERSION}"
RUN env && apt-get update && \
	apt-get install --no-install-recommends -y ca-certificates curl openssl libtasn1-6 \
		&& apt-get install -y --only-upgrade perl zlib1g \
		&& curl -L -o postgres-exporter.tar.gz \
			https://github.com/prometheus-community/postgres_exporter/releases/download/v${EXPORTER_VERSION}/postgres_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz \
		&& tar xzvf postgres-exporter.tar.gz \
		&& mv postgres_exporter-${EXPORTER_VERSION}.linux-amd64/postgres_exporter / \
		&& rm postgres-exporter.tar.gz \
		&& rm -rf postgres_exporter-${EXPORTER_VERSION}.linux-amd64/ \
		&& mkdir -p /usr/src/licenses/ \
		&& curl -sL -o /usr/src/licenses/postgres-exporter.LICENSE https://raw.githubusercontent.com/prometheus-community/postgres_exporter/master/LICENSE \
		&& apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

EXPOSE 9187
ENTRYPOINT [ "/postgres_exporter" ]
