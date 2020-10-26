FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.2

RUN set -eu \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    gettext \
    jq \
    uuid-runtime \
    wget \
    curl \
    openjdk-8-jdk \
    tar

RUN set -eu \
    && wget -q -O /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl \
    && chmod 755 /bin/kubectl

# COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
