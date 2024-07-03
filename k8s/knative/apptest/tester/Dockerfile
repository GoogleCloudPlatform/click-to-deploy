FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget dnsutils netcat jq \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/kubectl/1.24 \
    && wget -q -O /opt/kubectl/1.24/kubectl \
       https://storage.googleapis.com/kubernetes-release/release/v1.24.10/bin/linux/amd64/kubectl \
    && chmod 755 /opt/kubectl/1.24/kubectl \
    && ln -s /opt/kubectl/1.24/kubectl /usr/bin/kubectl

COPY tests/cert-manager.yaml tests/istio-gateway.yaml tests/knative-serving.yaml /tests/
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]

