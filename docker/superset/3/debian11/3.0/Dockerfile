FROM marketplace.gcr.io/google/c2d-debian11

ARG SUPERSET_VERSION="3.0.0"
ENV C2D_RELEASE "3.0.0"
ENV SUPERSET_VERSION ${SUPERSET_VERSION}
ENV FLASK_APP="superset.app:create_app()"
ENV SUPERSET_HOME=/var/lib/superset

# Installing python3 and dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libssl-dev libffi-dev python3-dev python3-pip libsasl2-dev openssl\
    libldap2-dev default-libmysqlclient-dev

# Create superset user & install dependencies
WORKDIR /home/superset
COPY requirements*.txt ./
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
        libsasl2-modules-gssapi-mit && \
    pip install --disable-pip-version-check --upgrade "pip==23.2.1" && \
    pip install -r requirements.txt && \
    pip install apache-superset==$SUPERSET_VERSION && \
    pip install sqlparse=='0.4.4'
# https://github.com/apache/superset/issues/23742

# Configure Filesystem
VOLUME /etc/superset
VOLUME /home/superset
VOLUME /var/lib/superset

EXPOSE 8088

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
# ENTRYPOINT ["tail", "-f", "/dev/null"]
