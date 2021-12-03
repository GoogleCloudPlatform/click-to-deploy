FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.4

# Add debian backport source repository
RUN set -x \
    && apt update \
    && apt -y install debian-keyring debian-archive-keyring \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138 \
    && echo 'deb http://ftp.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/stretch-backports.list \
    && apt update \
    && apt install -y \
        curl \
        jq \
        openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o cypher-shell.deb https://github.com/neo4j/cypher-shell/releases/download/4.0.1/cypher-shell_4.0.1_all.deb \
    && dpkg -i cypher-shell.deb \
    && rm -f cypher-shell.deb

COPY tests /tests
COPY tester.sh /tester.sh

WORKDIR /

ENTRYPOINT ["/tester.sh"]
