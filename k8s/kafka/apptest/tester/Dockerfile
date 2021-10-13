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
    openjdk-8-jre \
    netcat

RUN set -eu \
    && wget -q -O /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl \
    && chmod 755 /bin/kubectl \
    && curl -sSL https://archive.apache.org/dist/kafka/2.8.0/kafka_2.13-2.8.0.tgz -o "/opt/kafka_2.13-2.8.0.tgz" \
    && tar -xzf /opt/kafka_2.13-2.8.0.tgz -C /opt \
    && mv /opt/kafka_2.13-2.8.0 /opt/kafka

ENV  PATH="${PATH}:/opt/kafka/bin"
COPY tests/kafka-cluster-test.yaml /tests/kafka-cluster-test.yaml
COPY tests/kafka-exporter-test.yaml /tests/kafka-exporter-test.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
