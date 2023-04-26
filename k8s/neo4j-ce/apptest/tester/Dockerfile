FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.5

# Add debian backport source repository
RUN set -x \
    && apt update \
    && apt install -y \
        curl \
        jq \
        openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o cypher-shell.deb https://github.com/neo4j/cypher-shell/releases/download/4.2.2/cypher-shell_4.2.2_all.deb \
    && dpkg -i cypher-shell.deb \
    && rm -f cypher-shell.deb

COPY tests /tests
COPY tester.sh /tester.sh

WORKDIR /

ENTRYPOINT ["/tester.sh"]
