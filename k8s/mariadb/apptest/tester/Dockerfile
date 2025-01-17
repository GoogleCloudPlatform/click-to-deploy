FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tests/exporter-suite.yaml /tests/exporter-suite.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
