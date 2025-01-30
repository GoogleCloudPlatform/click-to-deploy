FROM marketplace.gcr.io/google/debian12

ARG SUPERSET_VERSION="4.0.2"
ENV C2D_RELEASE "4.0.2"
ENV SUPERSET_VERSION ${SUPERSET_VERSION}
ENV FLASK_APP="superset.app:create_app()"
ENV SUPERSET_HOME=/var/lib/superset

# Installing python3 and dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libssl-dev libffi-dev python3-dev python3-pip libsasl2-dev openssl\
    libldap2-dev default-libmysqlclient-dev

# Create superset user & install dependencies
WORKDIR /home/superset
RUN groupadd supergroup && \
    useradd -U -G supergroup superset && \
    mkdir -p /etc/superset && \
    mkdir -p $SUPERSET_HOME && \
    chown -R superset:superset /etc/superset && \
    chown -R superset:superset $SUPERSET_HOME && \
    apt-get update && \
    apt-get install -y \
        curl \
        freetds-bin \
        freetds-dev \
        libaio1 \
        libecpg-dev \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-2 \
        libsasl2-modules-gssapi-mit


# Prepare requirements
RUN echo "Prepare requirements..." \
    && curl -s -O -L "https://raw.githubusercontent.com/apache/superset/${SUPERSET_VERSION}/requirements/base.txt" \
    && curl -s -O -L "https://raw.githubusercontent.com/apache/superset/${SUPERSET_VERSION}/requirements/development.txt" \
    && sed -i 's/^-e.*//g' base.txt \
    && sed -i 's/^-r.*//g' base.txt \
    && sed -i 's/^-e.*//g' development.txt \
    && sed -i 's/^-r.*//g' development.txt


RUN apt -y install python3-pip python3-statsd \
    && pip install -r base.txt --break-system-packages \
    && pip install -r development.txt --break-system-packages \
    && pip install apache-superset==$SUPERSET_VERSION --break-system-packages

# Configure Filesystem
VOLUME /etc/superset
VOLUME /home/superset
VOLUME /var/lib/superset

EXPOSE 8088

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
