FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.8

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg2 \
    curl \
    wget \
    apt-transport-https

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main' >  /etc/apt/sources.list.d/pgdg.list \
        && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
        && apt update \
        && apt -y install postgresql-client-15 \
        && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/v1.24.10/bin/linux/amd64/kubectl \
      && chmod 755 /bin/kubectl

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tests/exporter-suite.yaml /tests/exporter-suite.yaml
COPY tester.sh /tester.sh

WORKDIR /

ENTRYPOINT ["/tester.sh"]
