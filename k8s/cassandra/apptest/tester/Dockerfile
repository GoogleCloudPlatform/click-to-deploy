FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gettext \
    jq \
    uuid-runtime \
    wget \
    python3 \
    python3-pip \
    python3-setuptools \
    && pip install --upgrade pip \
    && pip install --upgrade wheel \
    && pip install cqlsh futures \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/v1.24.10/bin/linux/amd64/kubectl \
      && chmod 755 /bin/kubectl

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
