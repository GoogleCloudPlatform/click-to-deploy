FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.8

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
    openjdk-17-jre \
    netcat-traditional

RUN set -eu \
    && curl -L -o /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod 755 /bin/kubectl \
    && curl -sSL https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -o "/opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    && tar -xzf /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
    && mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka

ENV  PATH="${PATH}:/opt/kafka/bin"
COPY tests/kafka-cluster-test.yaml /tests/kafka-cluster-test.yaml
COPY tests/kafka-exporter-test.yaml /tests/kafka-exporter-test.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
