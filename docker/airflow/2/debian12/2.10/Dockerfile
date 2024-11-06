ARG AIRFLOW_VERSION="2.10.3"
ARG AIRFLOW_EXTRAS="amazon,async,celery,cncf.kubernetes,dask,docker,elasticsearch,ftp,google,google_auth,grpc,hashicorp,http,ldap,microsoft.azure,mysql,odbc,pandas,postgres,redis,sendgrid,sftp,slack,ssh,statsd,virtualenv,apache-airflow-providers-cncf-kubernetes"

ARG AIRFLOW_HOME=/opt/airflow
ARG AIRFLOW_UID=50000
ARG AIRFLOW_USER_HOME_DIR=/home/airflow
ARG AIRFLOW_PIP_VERSION="24.3.1"


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


FROM marketplace.gcr.io/google/debian12 as airflow-build-image

ARG AIRFLOW_HOME=/opt/airflow
ARG AIRFLOW_UID=50000
ARG AIRFLOW_USER_HOME_DIR=/home/airflow

SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-o", "nounset", "-o", "nolog", "-c"]
ENV DEBIAN_FRONTEND=noninteractive LANGUAGE=C.UTF-8 LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    LC_CTYPE=C.UTF-8 LC_MESSAGES=C.UTF-8

RUN adduser --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password \
    --quiet "airflow" --uid "${AIRFLOW_UID}" --gid "0" --home "${AIRFLOW_USER_HOME_DIR}" && \
    mkdir -p ${AIRFLOW_HOME} && mkdir -p ${AIRFLOW_USER_HOME_DIR}/.local && \
    chown -R "airflow:0" "${AIRFLOW_USER_HOME_DIR}" ${AIRFLOW_HOME};

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-venv

USER airflow

# Additional development dependencies
ENV DEV_APT_DEPS="\
     apt-transport-https \
     apt-utils \
     build-essential \
     ca-certificates \
     dirmngr \
     freetds-bin \
     freetds-dev \
     gosu \
     krb5-user \
     ldap-utils \
     libffi-dev \
     libkrb5-dev \
     libldap2-dev \
     libpq-dev \
     libsasl2-2 \
     libsasl2-dev \
     libsasl2-modules \
     libssl-dev \
     locales  \
     lsb-release \
     nodejs \
     openssh-client \
     pkg-config \
     postgresql-client \
     python3 \
     python3-dev \
     sasl2-bin \
     software-properties-common \
     sqlite3 \
     sudo \
     unixodbc \
     unixodbc-dev \
     yarn"

ENV DEV_APT_COMMAND="\
    curl --silent --fail --location https://deb.nodesource.com/setup_20.x | \
    bash -o pipefail -o errexit -o nolog - \
    && curl --silent https://dl.yarnpkg.com/debian/pubkey.gpg | \
    apt-key add - >/dev/null 2>&1\
    && echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list"

USER root

RUN apt-get update \
    && apt-get install --no-install-recommends -yqq apt-utils >/dev/null 2>&1 \
    && apt-get install -y --no-install-recommends curl ca-certificates gnupg2 \
    && mkdir -pv /usr/share/man/man1 \
    && mkdir -pv /usr/share/man/man7 \
    && bash -o pipefail -o errexit -o nounset -o nolog -c "${DEV_APT_COMMAND}" \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEV_APT_DEPS} \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow

ARG AIRFLOW_EXTRAS
ARG AIRFLOW_VERSION
ARG AIRFLOW_PIP_VERSION
ARG AIRFLOW_HOME
ARG AIRFLOW_USER_HOME_DIR
ARG AIRFLOW_UID

# Set additional environment variables
ENV AIRFLOW_PIP_VERSION=${AIRFLOW_PIP_VERSION} \
    AIRFLOW_VERSION=${AIRFLOW_VERSION} \
    AIRFLOW_EXTRAS=${AIRFLOW_EXTRAS} \
    AIRFLOW_PRE_CACHED_PIP_PACKAGES="false" \
    INSTALL_PROVIDERS_FROM_SOURCES="false" \
    AIRFLOW_INSTALLATION_METHOD="apache-airflow" \
    PATH=${PATH}:${AIRFLOW_USER_HOME_DIR}/.local/bin \
    AIRFLOW_PIP_VERSION=${AIRFLOW_PIP_VERSION} \
    AIRFLOW_USER_HOME_DIR=${AIRFLOW_USER_HOME_DIR} \
    AIRFLOW_HOME=${AIRFLOW_HOME} \
    AIRFLOW_UID=${AIRFLOW_UID} \
    INSTALL_MYSQL_CLIENT="true" \
    INSTALL_MSSQL_CLIENT="true" \
    PIP_USER="false"

FROM marketplace.gcr.io/google/debian12 as main

# Copy necessary binaries and settings from build stage
COPY --from=ospo /usr/src /usr/src

SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-o", "nounset", "-o", "nolog", "-c"]

# Set up necessary privileges
ARG AIRFLOW_USER_HOME_DIR
ARG AIRFLOW_HOME
ARG AIRFLOW_UID
ARG AIRFLOW_PIP_VERSION
ARG AIRFLOW_VERSION

ENV AIRFLOW_VERSION=${AIRFLOW_VERSION} \
    DEBIAN_FRONTEND=noninteractive LANGUAGE=C.UTF-8 LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    LC_CTYPE=C.UTF-8 LC_MESSAGES=C.UTF-8 \
    AIRFLOW_PIP_VERSION=${AIRFLOW_PIP_VERSION}

# Runtime dependencies
ENV RUNTIME_APT_DEPS="\
       apt-transport-https \
       apt-utils \
       ca-certificates \
       curl \
       dumb-init \
       freetds-bin \
       krb5-user \
       ldap-utils \
       libffi8 \
       libldap-common \
       libsasl2-2 \
       libsasl2-modules \
       libssl-dev \
       locales  \
       lsb-release \
       netcat-traditional \
       openssh-client \
       pkg-config \
       postgresql-client \
       dh-python \
       python3 \
       python3-venv \
       pkg-config \
       rsync \
       sasl2-bin \
       sqlite3 \
       sudo \
       unixodbc"

ENV RUNTIME_APT_COMMAND="echo" \
    INSTALL_MYSQL_CLIENT="true" \
    INSTALL_MSSQL_CLIENT="true" \
    AIRFLOW_INSTALLATION_METHOD="apache-airflow" \
    AIRFLOW_UID=${AIRFLOW_UID} \
    AIRFLOW__DATABASE__LOAD_EXAMPLES="false" \
    AIRFLOW_USER_HOME_DIR=${AIRFLOW_USER_HOME_DIR} \
    AIRFLOW_HOME=${AIRFLOW_HOME} \
    PATH="${AIRFLOW_USER_HOME_DIR}/.local/bin:${PATH}" \
    GUNICORN_CMD_ARGS="--worker-tmp-dir /dev/shm" \
    PIP_USER="false"

# Install and configure runtime environment
RUN apt-get update \
    && apt-get install --no-install-recommends -yqq apt-utils >/dev/null 2>&1 \
    && apt-get install -y --no-install-recommends curl ca-certificates gnupg2 \
    && mkdir -pv /usr/share/man/man1 \
    && mkdir -pv /usr/share/man/man7 \
    && bash -o pipefail -o errexit -o nounset -o nolog -c "${RUNTIME_APT_COMMAND}" \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${RUNTIME_APT_DEPS} \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/log/* \
    && ln -s /usr/bin/python3 /usr/bin/python

# Install Gosu
# /usr/sbin/gosu
ENV GOSU_VERSION 1.17
RUN set -eux; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ca-certificates \
		gpg \
		gpgv \
		libjemalloc2 \
		pwgen \
		tzdata \
		xz-utils \
		zstd ; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get install -y --no-install-recommends \
		dirmngr \
		gpg-agent \
		wget; \
	rm -rf /var/lib/apt/lists/*; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -q -O /usr/sbin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -q -O /usr/sbin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	GNUPGHOME="$(mktemp -d)"; \
	export GNUPGHOME; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/sbin/gosu.asc /usr/sbin/gosu; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/sbin/gosu.asc; \
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] ||	apt-mark manual $savedAptMark >/dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	chmod +x /usr/sbin/gosu; \
	gosu --version; \
	gosu nobody true

# Create and activate virtual environment
USER root

RUN python3 -m venv ${AIRFLOW_USER_HOME_DIR}/venv
ENV PATH="${AIRFLOW_USER_HOME_DIR}/venv/bin:${PATH}"

# Continue installation and set up user permissions
COPY scripts/docker/install_mysql.sh /scripts/docker/install_mssql.sh /scripts/docker/
RUN chmod a+x /scripts/docker/install_mysql.sh /scripts/docker/install_mssql.sh \
    && sync \
    && /scripts/docker/install_mysql.sh prod \
    && /scripts/docker/install_mssql.sh \
    && adduser --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password --quiet "airflow" --uid "${AIRFLOW_UID}" --gid "0" --home "${AIRFLOW_USER_HOME_DIR}" \
    && mkdir -pv "${AIRFLOW_HOME}" \
    && mkdir -pv "${AIRFLOW_HOME}/dags" \
    && mkdir -pv "${AIRFLOW_HOME}/logs" \
    && chown -R airflow:0 "${AIRFLOW_USER_HOME_DIR}" "${AIRFLOW_HOME}" \
    && chmod -R g+rw "${AIRFLOW_USER_HOME_DIR}" "${AIRFLOW_HOME}" \
    && find "${AIRFLOW_HOME}" -executable -print0 | xargs -0 chmod g+x \
    && find "${AIRFLOW_USER_HOME_DIR}" -executable -print0 | xargs -0 chmod g+x

# Install required tools
COPY scripts/docker/install_mysql.sh scripts/docker/install_mssql.sh /scripts/docker/
RUN /scripts/docker/install_mysql.sh dev && /scripts/docker/install_mssql.sh
ENV PATH=${PATH}:/opt/mssql-tools/bin

# Change user to root then run pip install script and revert back to airflow user
USER root
COPY --chown=airflow:0 scripts/docker/install_pip_version.sh /scripts/docker/
RUN chmod +x /scripts/docker/install_pip_version.sh
RUN /scripts/docker/install_pip_version.sh
USER airflow

# Final environment settings and running installations
ENV INSTALL_FROM_PYPI="true" \
    EAGER_UPGRADE_ADDITIONAL_REQUIREMENTS="dill<0.3.3 certifi<2021.0.0 google-ads<14.0.1"

WORKDIR /opt/airflow
COPY --chown=airflow:0 scripts/docker/install_airflow.sh /scripts/docker/

RUN /scripts/docker/install_airflow.sh \
    && mkdir -p "${AIRFLOW_USER_HOME_DIR}/.local" \
    && find "${AIRFLOW_USER_HOME_DIR}/.local/" -name '*.pyc' -print0 | xargs -0 rm -f || true \
    && find "${AIRFLOW_USER_HOME_DIR}/.local/" -type d -name '__pycache__' -print0 | xargs -0 rm -rf || true \
    && find "${AIRFLOW_USER_HOME_DIR}/.local" -executable -print0 | xargs --null chmod g+x \
    && find "${AIRFLOW_USER_HOME_DIR}/.local" -print0 | xargs --null chmod g+rw

RUN pip3 install psycopg2-binary

# Copy pre-built local environment for Airflow and set up entry points
COPY --chown=airflow:0 --from=airflow-build-image \
     "${AIRFLOW_USER_HOME_DIR}/.local" "${AIRFLOW_USER_HOME_DIR}/.local"
COPY --chown=airflow:0 scripts/prod/entrypoint_prod.sh /entrypoint
COPY --chown=airflow:0 scripts/prod/clean-logs.sh /clean-logs

# Ensure scripts are executable and adjust file permissions appropriately
USER root
RUN chmod a+x /entrypoint /clean-logs \
    && chmod g=u /etc/passwd \
    && chmod g+w "${AIRFLOW_USER_HOME_DIR}/.local"

# Modify secure path to include virtual environment
RUN sed --in-place=.bak "s/secure_path=\"/secure_path=\"\/.venv\/bin:/" /etc/sudoers

USER airflow

# Environment settings for runtime
ENV DUMB_INIT_SETSID="1" \
    PS1="(airflow)" \
    LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6"

# Set work directory and expose port for webserver
WORKDIR ${AIRFLOW_HOME}
EXPOSE 8080

# Run as airflow user
USER ${AIRFLOW_UID}

# Define Airflow release version
ENV C2D_RELEASE 2.10.3

# Set default entrypoint and command for the container
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint"]
CMD ["webserver"]
