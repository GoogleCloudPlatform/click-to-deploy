#FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.3
FROM gcr.io/ccm-ops-test-adhoc/testrunner:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    mysql-client \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY tests/* /tests/
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
