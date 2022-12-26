FROM marketplace.gcr.io/google/debian11 AS build

ENV KEYCLOAK_VERSION 18.0.2
ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz

ADD $KEYCLOAK_DIST /tmp/keycloak/

RUN (cd /tmp/keycloak && \
    tar -xvf /tmp/keycloak/keycloak-*.tar.gz && \
    rm /tmp/keycloak/keycloak-*.tar.gz) || true

RUN mv /tmp/keycloak/keycloak-* /opt/keycloak && mkdir -p /opt/keycloak/data

RUN chmod -R g+rwX /opt/keycloak

#replace vulnerable library
ENV SSHDCOMMON_VERSION 2.9.2
RUN rm -f /opt/keycloak/lib/lib/main/org.apache.sshd.sshd-common-2.7.0.jar
ARG SSHDCOMMON_DIST=https://repo1.maven.org/maven2/org/apache/sshd/sshd-common/$SSHDCOMMON_VERSION/sshd-common-$SSHDCOMMON_VERSION.jar
ADD $SSHDCOMMON_DIST /opt/keycloak/org.apache.sshd.sshd-common-$SSHDCOMMON_VERSION.jar
RUN ln -s /opt/keycloak/org.apache.sshd.sshd-common-$SSHDCOMMON_VERSION.jar \
    /opt/keycloak/lib/lib/main/org.apache.sshd.sshd-common-2.7.0.jar

FROM marketplace.gcr.io/google/debian11
ENV LANGUAGE=C.UTF-8 LANG=C.UTF-8 LC_ALL=C.UTF-8 LC_CTYPE=C.UTF-8 LC_MESSAGES=C.UTF-8

COPY --from=build --chown=1000:0 /opt/keycloak /opt/keycloak

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl locales openjdk-11-jre-headless libh2-java \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN cp /usr/share/java/h2-1.4.197.jar /opt/keycloak/lib/lib/main/com.h2database.h2-1.4.197.jar

ENV KC_DB=postgres
RUN /opt/keycloak/bin/kc.sh build --db=postgres

ENV C2D_RELEASE 18.0.2

USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "/opt/keycloak/bin/kc.sh" ]
