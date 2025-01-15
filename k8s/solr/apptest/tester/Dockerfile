FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.8

RUN set -eu \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        gettext \
        jq \
        uuid-runtime \
        wget \
        curl

RUN set -eu \
    && curl -L -o /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.23.15/bin/linux/amd64/kubectl \
    && chmod 755 /bin/kubectl

COPY tests/solrCloud-test.yaml /tests/solrCloud-test.yaml
COPY tests/solr-exporter-test.yaml /tests/solr-exporter-test.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
