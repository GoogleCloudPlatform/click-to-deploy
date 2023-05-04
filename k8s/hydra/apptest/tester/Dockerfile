FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    postgresql-client \
    curl \
    gettext \
    python3 \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/v1.23.15/bin/linux/amd64/kubectl \
      && chmod 755 /bin/kubectl

COPY tests/* /tests/
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
