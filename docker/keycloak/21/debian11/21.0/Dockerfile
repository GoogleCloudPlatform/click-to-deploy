FROM marketplace.gcr.io/google/c2d-debian11 AS build

ENV KEYCLOAK_VERSION 21.0.2
ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz

ADD $KEYCLOAK_DIST /tmp/keycloak/

RUN (cd /tmp/keycloak && \
    tar -xvf /tmp/keycloak/keycloak-*.tar.gz && \
    rm /tmp/keycloak/keycloak-*.tar.gz) || true

RUN mv /tmp/keycloak/keycloak-* /opt/keycloak && mkdir -p /opt/keycloak/data

RUN chmod -R g+rwX /opt/keycloak

FROM marketplace.gcr.io/google/c2d-debian11
ENV LANGUAGE=C.UTF-8 LANG=C.UTF-8 LC_ALL=C.UTF-8 LC_CTYPE=C.UTF-8 LC_MESSAGES=C.UTF-8

COPY --from=build --chown=1000:0 /opt/keycloak /opt/keycloak

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates-java

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
          ca-certificates-java \
          curl \
          locales \
          openjdk-17-jre-headless \
          libh2-java \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


ENV KC_DB=postgres
RUN /opt/keycloak/bin/kc.sh build --db=postgres

ENV C2D_RELEASE 21.0.2

USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "/opt/keycloak/bin/kc.sh" ]
