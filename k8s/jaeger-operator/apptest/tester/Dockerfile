FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl dnsutils netcat-traditional jq \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/kubectl/1.26 \
    && curl -L -o /opt/kubectl/1.26/kubectl \
       https://storage.googleapis.com/kubernetes-release/release/v1.26.1/bin/linux/amd64/kubectl \
    && chmod 755 /opt/kubectl/1.26/kubectl \
    && ln -s /opt/kubectl/1.26/kubectl /usr/bin/kubectl

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
