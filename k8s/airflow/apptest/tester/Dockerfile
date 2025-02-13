FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl dnsutils netcat-traditional jq \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/kubectl/1.21 \
    && curl -L -o kubectl \
       https://storage.googleapis.com/kubernetes-release/release/v1.21.6/bin/linux/amd64/kubectl \
    && mv kubectl /opt/kubectl/1.21/ \
    && chmod 755 /opt/kubectl/1.21/kubectl \
    && ln -s /opt/kubectl/1.21/kubectl /usr/bin/kubectl

COPY tests/apache-airflow.yaml /tests/
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
