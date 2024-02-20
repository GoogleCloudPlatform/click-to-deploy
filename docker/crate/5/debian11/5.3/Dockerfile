FROM marketplace.gcr.io/google/c2d-debian11

RUN apt-get update \
    && apt-get install curl python3 python3-pip -y --no-install-recommends \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd crate \
    && useradd -u 1000 -g crate -d /crate crate

#install crate
WORKDIR /crate

ENV CRATE_VERSION 5.3.9
ARG CRATE_DIST=https://cdn.crate.io/downloads/releases/cratedb/x64_linux/crate-${CRATE_VERSION}.tar.gz

ADD $CRATE_DIST /tmp/

RUN (tar -xf /tmp/crate-${CRATE_VERSION}.tar.gz -C /crate --strip-components=1 &&\
    rm /tmp/crate-*.tar.gz) || true

#install libraries licenses
ADD https://raw.githubusercontent.com/antlr/antlr4/master/LICENSE.txt /crate/antlr4_LICENSE
ADD https://raw.githubusercontent.com/aws/aws-sdk-java/master/LICENSE.txt /crate/aws-sdk-java_LICENSE
ADD https://raw.githubusercontent.com/FasterXML/jackson-core/2.15/LICENSE /crate/jackson-core_LICENSE
ADD https://raw.githubusercontent.com/FasterXML/jackson-databind/2.15/LICENSE /crate/jackson-databind_LICENSE
ADD https://raw.githubusercontent.com/apache/lucene/main/LICENSE.txt /crate/lucene_LICENSE
ADD https://raw.githubusercontent.com/netty/netty/4.1/LICENSE.txt /crate/netty_LICENSE
ADD https://raw.githubusercontent.com/qos-ch/slf4j/master/LICENSE.txt /crate/slf4j_LICENSE
ADD https://raw.githubusercontent.com/apache/logging-log4j2/2.x/LICENSE.txt /crate/log4j_LICENSE

#install crash
ENV CRASH_VERSION=0.28.0
ARG CRASH_DIST=https://cdn.crate.io/downloads/releases/crash_standalone_${CRASH_VERSION}

ADD $CRASH_DIST /tmp/

RUN mv /tmp/crash_standalone_${CRASH_VERSION} /usr/local/bin/crash \
    && chmod +x /usr/local/bin/crash
ADD https://raw.githubusercontent.com/crate/crash/master/LICENSE /crate/crash_LICENSE
ENV PATH /crate/bin:$PATH
# Default heap size for Docker, can be overwritten by args
ENV CRATE_HEAP_SIZE 512M

#add prometheus exporter
RUN curl https://repo1.maven.org/maven2/io/crate/crate-jmx-exporter/1.0.0/crate-jmx-exporter-1.0.0.jar -o /crate/lib/exporter.jar
ENV CRATE_JAVA_OPTS "-javaagent:/crate/lib/exporter.jar=7071 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false"

RUN mkdir -p /data/data /data/log

VOLUME /data

WORKDIR /data

# http: 4200 tcp
# transport: 4300 tcp
# postgres protocol ports: 5432 tcp
EXPOSE 4200 4300 5432

ENV C2D_RELEASE 5.3.9

COPY --chown=1000:0 config/crate.yml /crate/config/crate.yml
COPY --chown=1000:0 config/log4j2.properties /crate/config/log4j2.properties

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["crate"]
