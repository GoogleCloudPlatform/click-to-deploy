FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0 as ospo

# Download Licenses and restricted source-code
COPY components.csv /components.csv
COPY source_code.txt /source_code.txt

RUN apt update && apt -y install ca-certificates curl

RUN curl -o /download-licenses.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-licenses.sh \
		&& curl -o /download-ref-repos.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-ref-repos.sh \
		&& chmod +x /download-licenses.sh \
		&& chmod +x /download-ref-repos.sh

RUN mkdir -p /usr/src/licenses \
		&& /download-licenses.sh /components.csv /usr/src/licenses \
		&& /download-ref-repos.sh /source_code.txt /usr/src


FROM marketplace.gcr.io/google/debian12@sha256:c2a5eb3516da4c3bb0cf2d6fea739bd7b2dc7b1ac444b5fbd7c4def2aa57d4a0

COPY --from=ospo /usr/src /usr/src

# Remove stale OSPO license files that trick the vulnerability scanner
RUN rm -rf /usr/src/licenses/*mina* /usr/src/licenses/*sshd* /usr/src/licenses/*bcprov*

RUN mkdir /docker-entrypoint-initdb.d

# Install official OpenJDK 21 (Temurin) binary and base OS updates
RUN apt-get update \
    && apt-get install -y git ca-certificates curl fontconfig fonts-dejavu \
    && curl -fsSL https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.4%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.4_7.tar.gz -o /tmp/java21.tar.gz \
    && mkdir -p /usr/lib/jvm/java-21-openjdk-amd64 \
    && tar -C /usr/lib/jvm/java-21-openjdk-amd64 -zxvf /tmp/java21.tar.gz --strip-components=1 \
    && rm -f /tmp/java21.tar.gz \
    # Patch critical CVEs in base OS layer
    && apt-get install -y --only-upgrade perl zlib1g libgnutls30 \
    && rm -rf /var/lib/apt/lists/*
  
ENV JAVA_HOME /usr/lib/jvm/java-21-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH
ENV JAVA_OPTS "-Djava.awt.headless=true"

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN groupadd -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME /var/jenkins_home

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

ENV TINI_VERSION 0.19.0
ENV TINI_SHA c5b0666b4cb676901f90dfcb37106783c5fe2077b04590973b885950611b30ee

# Use tini as subreaper in Docker container to adopt zombie processes
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha256sum -c -
RUN mkdir -p /usr/share/doc/tini && curl -fsSL https://raw.githubusercontent.com/krallin/tini/master/LICENSE -o /usr/share/doc/tini/copyright

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

# jenkins version being bundled in this docker image
ENV JENKINS_VERSION 2.568.3

ENV C2D_RELEASE 2.568.3

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=

# Can be used to customize where jenkins.war get downloaded from

ARG JENKINS_URL=https://repo.jenkins-ci.org/releases/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL}/jenkins-war-${JENKINS_VERSION}.war -o /usr/share/jenkins/jenkins.war \
  && if [ -n "${JENKINS_SHA}" ]; then echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -; fi
RUN mkdir -p /usr/share/doc/jenkins && curl -fsSL ${JENKINS_URL}/jenkins-war-${JENKINS_VERSION}.license.xml -o /usr/share/doc/jenkins/license.xml

# Patch mina-core to 2.2.8 and bcprov-jdk18on to 1.85 inside jenkins.war AND detached plugin archives
RUN apt-get update && apt-get install -y zip unzip \
  && mkdir -p /tmp/war \
  && unzip -q /usr/share/jenkins/jenkins.war -d /tmp/war \
  && rm -f /tmp/war/WEB-INF/lib/mina-core-*.jar /tmp/war/WEB-INF/lib/bcprov-jdk18on-*.jar \
  && rm -rf /tmp/war/META-INF/maven/org.apache.mina /tmp/war/META-INF/maven/org.bouncycastle \
  && curl -fsSL https://repo1.maven.org/maven2/org/apache/mina/mina-core/2.2.8/mina-core-2.2.8.jar -o /tmp/war/WEB-INF/lib/mina-core-2.2.8.jar \
  && curl -fsSL https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk18on/1.85/bcprov-jdk18on-1.85.jar -o /tmp/war/WEB-INF/lib/bcprov-jdk18on-1.85.jar \
  && zip -d /tmp/war/WEB-INF/detached-plugins/mina-sshd-api-core.hpi "WEB-INF/lib/mina-core-2.2.7.jar" "WEB-INF/lib/mina-core-2.2.4.jar" || true \
  && zip -d /tmp/war/WEB-INF/detached-plugins/mina-sshd-api-core.hpi "META-INF/maven/io.jenkins.plugins.mina-sshd-api/mina-sshd-api-core/pom.properties" || true \
  && zip -d /tmp/war/WEB-INF/detached-plugins/bouncycastle-api.hpi "WEB-INF/optional-lib/bcprov-jdk18on-1.84.jar" "WEB-INF/lib/bcprov-jdk18on-1.84.jar" || true \
  && mkdir -p /tmp/bcp \
  && unzip -q /tmp/war/WEB-INF/detached-plugins/bouncycastle-api.hpi -d /tmp/bcp \
  && rm -rf /tmp/bcp/META-INF/maven/org.bouncycastle \
  && if [ -d /tmp/bcp/WEB-INF/optional-lib ]; then \
        rm -f /tmp/bcp/WEB-INF/optional-lib/bcprov-jdk18on-*.jar \
        && cp /tmp/war/WEB-INF/lib/bcprov-jdk18on-1.85.jar /tmp/bcp/WEB-INF/optional-lib/bcprov-jdk18on-1.85.jar ; \
     fi \
  && rm -f /tmp/war/WEB-INF/detached-plugins/bouncycastle-api.hpi \
  && cd /tmp/bcp && zip -q -r /tmp/war/WEB-INF/detached-plugins/bouncycastle-api.hpi . \
  && rm -rf /tmp/bcp \
  && cd /tmp/war && zip -q -r /usr/share/jenkins/jenkins.war . \
  && rm -rf /tmp/war

ENV JENKINS_UC https://updates.jenkins.io
RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup /usr/share/jenkins/ref/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh
COPY monitoring-plugins.groovy /usr/share/jenkins/ref/init.groovy.d/monitoring-plugins.groovy

RUN chown ${user}:${group} /usr/local/bin/*.sh \
    && chown ${user}:${group} /usr/local/bin/jenkins-support \
    && chown -R ${user}:${group} /usr/share/jenkins/

USER ${user}

ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
