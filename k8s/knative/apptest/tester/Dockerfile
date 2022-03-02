FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.4

ARG KUBECTL_VERSION=1.12.0
ARG KAFKA_VERSION=2.8.0
ARG SCALA_VERSION=2.13

RUN set -eu \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    gettext \
    jq \
    uuid-runtime \
    wget \
    curl \
    openjdk-8-jre \
    netcat

RUN set -eu \
    && wget -q -O /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod 755 /bin/kubectl

COPY tests/knative-cluster-test.yaml /tests/knative-cluster-test.yaml
COPY tests/knative-exporter-test.yaml /tests/knative-exporter-test.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
