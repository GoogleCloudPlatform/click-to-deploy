FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    netcat \
    dnsutils \
    default-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN set -x && \
    wget https://archive.apache.org/dist/activemq/5.15.12/apache-activemq-5.15.12-bin.tar.gz \
    && tar -xvzf apache-activemq-5.15.12-bin.tar.gz \
    && cp -r apache-activemq-5.15.12 /opt/activemq

COPY tests /tests
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
