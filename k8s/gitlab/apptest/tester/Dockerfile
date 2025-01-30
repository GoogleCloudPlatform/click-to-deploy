FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    ca-certificates \
    curl \
    wget \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl \
      && chmod 755 /bin/kubectl

COPY tests/* /tests/
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]
