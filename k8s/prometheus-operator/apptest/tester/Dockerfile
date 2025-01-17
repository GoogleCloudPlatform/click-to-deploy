FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl dnsutils netcat-traditional jq \
    && rm -rf /var/lib/apt/lists/*

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
