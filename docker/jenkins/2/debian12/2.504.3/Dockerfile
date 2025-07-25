FROM marketplace.gcr.io/google/debian12 as ospo

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


FROM marketplace.gcr.io/google/debian12

COPY --from=ospo /usr/src /usr/src

RUN mkdir /docker-entrypoint-initdb.d

RUN apt-get update \
    && apt-get install -y \
      git ca-certificates curl openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

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
ENV JENKINS_VERSION 2.504.3

ENV C2D_RELEASE 2.504.3

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=ea8883431b8b5ef6b68fe0e5817c93dc0a11def380054e7de3136486796efeb0

# Can be used to customize where jenkins.war get downloaded from

ARG JENKINS_URL=https://repo.jenkins-ci.org/releases/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL}/jenkins-war-${JENKINS_VERSION}.war -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -
RUN mkdir -p /usr/share/doc/jenkins && curl -fsSL ${JENKINS_URL}/jenkins-war-${JENKINS_VERSION}.license.xml -o /usr/share/doc/jenkins/license.xml

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
