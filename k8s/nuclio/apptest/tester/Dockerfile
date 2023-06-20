FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.5

ARG DOCKER_CLI_VERSION="17.09.0-ce"
ENV DOWNLOAD_URL="https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_CLI_VERSION.tgz"

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl dnsutils netcat \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://github.com/nuclio/nuclio/releases/download/1.10.8/nuctl-1.10.8-linux-amd64 -O /usr/bin/nuctl \
    && chmod a+x /usr/bin/nuctl \
    && mkdir -p /tmp/download \
    && curl -L $DOWNLOAD_URL | tar -xz -C /tmp/download \
    && mv /tmp/download/docker/docker /usr/bin/ \
    && rm -rf /tmp/download

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tester.sh /tester.sh
COPY helloworld.py /helloworld.py

WORKDIR /
ENTRYPOINT ["/tester.sh"]
