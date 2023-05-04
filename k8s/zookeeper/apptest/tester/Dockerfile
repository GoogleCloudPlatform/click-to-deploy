FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.5

RUN set -eu \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    gettext \
    jq \
    uuid-runtime \
    wget \
    curl \
    openjdk-11-jdk \
    tar

ENV ZK_VERSION 3.8.1

RUN set -eu \
    && wget -q -O /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.24.10/bin/linux/amd64/kubectl \
    && chmod 755 /bin/kubectl \
    && wget -q -O /opt/zookeeper-${ZK_VERSION}.tar.gz https://archive.apache.org/dist/zookeeper/zookeeper-${ZK_VERSION}/apache-zookeeper-${ZK_VERSION}-bin.tar.gz \
    && tar -xvf /opt/zookeeper-${ZK_VERSION}.tar.gz -C /opt \
    && mv /opt/apache-zookeeper-${ZK_VERSION}-bin /opt/zookeeper

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
