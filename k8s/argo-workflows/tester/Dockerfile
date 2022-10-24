FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.4

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget dnsutils netcat jq \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/kubectl/1.22 \
    && wget -q -O /opt/kubectl/1.22/kubectl \
       https://storage.googleapis.com/kubernetes-release/release/v1.22.6/bin/linux/amd64/kubectl \
    && chmod 755 /opt/kubectl/1.22/kubectl \
    && ln -s /opt/kubectl/1.22/kubectl /usr/bin/kubectl

RUN curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.4.2/argo-linux-amd64.gz \
    && gunzip argo-linux-amd64.gz \
    && chmod +x argo-linux-amd64 \
    && mv ./argo-linux-amd64 /usr/local/bin/argo \
    && argo version

COPY tests/gogs.yaml /tests/
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
