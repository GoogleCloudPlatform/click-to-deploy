FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget netcat \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/kubectl/1.21 \
    && wget -q -O /opt/kubectl/1.21/kubectl \
       https://storage.googleapis.com/kubernetes-release/release/v1.21.6/bin/linux/amd64/kubectl \
    && chmod 755 /opt/kubectl/1.21/kubectl \
    && ln -s /opt/kubectl/1.21/kubectl /usr/bin/kubectl

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
