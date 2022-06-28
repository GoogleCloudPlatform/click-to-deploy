FROM marketplace.gcr.io/google/debian11:latest

ARG SUPERSET_VERSION="1.5.0"
ENV C2D_RELEASE "1.5.0"
ENV SUPERSET_VERSION ${SUPERSET_VERSION}
ENV FLASK_APP="superset.app:create_app()"
ENV SUPERSET_HOME=/var/lib/superset

# Installing python3 and dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libssl-dev libffi-dev python3-dev python3-pip libsasl2-dev \
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
        libpq-dev \
        libsasl2-2 \
        libsasl2-modules-gssapi-mit && \
    pip install apache-superset==$SUPERSET_VERSION && \
    pip install MarkupSafe==2.0.1 && \
    pip install psycopg2-binary && \
    pip install pillow && \
    pip install mysqlclient && \
    pip install statsd && \
    pip install statsd-client

# Configure Filesystem
VOLUME /etc/superset
VOLUME /home/superset
VOLUME /var/lib/superset

EXPOSE 8088

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
