ARG AIRFLOW_VERSION="2.5.0"
ARG AIRFLOW_EXTRAS="amazon,async,celery,cncf.kubernetes,dask,docker,elasticsearch,ftp,google,google_auth,grpc,hashicorp,http,ldap,microsoft.azure,mysql,odbc,pandas,postgres,redis,sendgrid,sftp,slack,ssh,statsd,virtualenv"

ARG AIRFLOW_HOME=/opt/airflow
ARG AIRFLOW_UID="50000"
ARG AIRFLOW_USER_HOME_DIR=/home/airflow
ARG AIRFLOW_PIP_VERSION="21.3.1"

FROM marketplace.gcr.io/google/debian11 as airflow-build-image

SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-o", "nounset", "-o", "nolog", "-c"]
ENV DEBIAN_FRONTEND=noninteractive LANGUAGE=C.UTF-8 LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    LC_CTYPE=C.UTF-8 LC_MESSAGES=C.UTF-8

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
     postgresql-client \
     python3 \
     python3-pip \
     python3-dev \
     sasl2-bin \
     software-properties-common \
     sqlite3 \
     sudo \
     unixodbc \
     unixodbc-dev \
     yarn"

ENV DEV_APT_COMMAND="\
    curl --silent --fail --location https://deb.nodesource.com/setup_14.x | \
    bash -o pipefail -o errexit -o nolog - \
    && curl --silent https://dl.yarnpkg.com/debian/pubkey.gpg | \
    apt-key add - >/dev/null 2>&1\
    && echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list"

RUN apt-get update \
    && apt-get install --no-install-recommends -yqq apt-utils >/dev/null 2>&1 \
    && apt-get install -y --no-install-recommends curl gnupg2 \
    && mkdir -pv /usr/share/man/man1 \
    && mkdir -pv /usr/share/man/man7 \
    && bash -o pipefail -o errexit -o nounset -o nolog -c "${DEV_APT_COMMAND}" \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEV_APT_DEPS} \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG AIRFLOW_EXTRAS
ARG AIRFLOW_VERSION
ARG AIRFLOW_PIP_VERSION
ARG AIRFLOW_HOME
ARG AIRFLOW_USER_HOME_DIR
ARG AIRFLOW_UID

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
    PIP_USER="true"

COPY scripts/docker/install_mysql.sh scripts/docker/install_mssql.sh /scripts/docker/

RUN /scripts/docker/install_mysql.sh dev && /scripts/docker/install_mssql.sh
ENV PATH=${PATH}:/opt/mssql-tools/bin

RUN adduser --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password \
       --quiet "airflow" --uid "${AIRFLOW_UID}" --gid "0" --home "${AIRFLOW_USER_HOME_DIR}" && \
    mkdir -p ${AIRFLOW_HOME} && chown -R "airflow:0" "${AIRFLOW_USER_HOME_DIR}" ${AIRFLOW_HOME}

USER airflow

COPY --chown=airflow:0 scripts/docker/install_pip_version.sh /scripts/docker/

RUN /scripts/docker/install_pip_version.sh

ENV INSTALL_FROM_PYPI="true" \
    EAGER_UPGRADE_ADDITIONAL_REQUIREMENTS="dill<0.3.3 certifi<2021.0.0 google-ads<14.0.1"

WORKDIR /opt/airflow

COPY --chown=airflow:0 scripts/docker/install_airflow.sh /scripts/docker/

RUN /scripts/docker/install_airflow.sh \
    && find "${AIRFLOW_USER_HOME_DIR}/.local/" -name '*.pyc' -print0 | xargs -0 rm -f || true \
    && find "${AIRFLOW_USER_HOME_DIR}/.local/" -type d -name '__pycache__' -print0 | xargs -0 rm -rf || true \
    && find "${AIRFLOW_USER_HOME_DIR}/.local" -executable -print0 | xargs --null chmod g+x \
    && find "${AIRFLOW_USER_HOME_DIR}/.local" -print0 | xargs --null chmod g+rw

FROM marketplace.gcr.io/google/debian11 as main

SHELL ["/bin/bash", "-o", "pipefail", "-o", "errexit", "-o", "nounset", "-o", "nolog", "-c"]

ARG AIRFLOW_USER_HOME_DIR
ARG AIRFLOW_HOME
ARG AIRFLOW_UID
ARG AIRFLOW_PIP_VERSION
ARG AIRFLOW_VERSION

ENV AIRFLOW_VERSION=${AIRFLOW_VERSION} \
    DEBIAN_FRONTEND=noninteractive LANGUAGE=C.UTF-8 LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    LC_CTYPE=C.UTF-8 LC_MESSAGES=C.UTF-8 \
    AIRFLOW_PIP_VERSION=${AIRFLOW_PIP_VERSION}

ENV RUNTIME_APT_DEPS="\
       apt-transport-https \
       apt-utils \
       ca-certificates \
       curl \
       dumb-init \
       freetds-bin \
       gosu \
       krb5-user \
       ldap-utils \
       libffi7 \
       libldap-2.4-2 \
       libsasl2-2 \
       libsasl2-modules \
       libssl1.1 \
       locales  \
       lsb-release \
       netcat \
       openssh-client \
       postgresql-client \
       python2 \
       python3 \
       python3-pip \
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
    AIRFLOW__CORE__LOAD_EXAMPLES="false" \
    AIRFLOW_USER_HOME_DIR=${AIRFLOW_USER_HOME_DIR} \
    AIRFLOW_HOME=${AIRFLOW_HOME} \
    PATH="${AIRFLOW_USER_HOME_DIR}/.local/bin:${PATH}" \
    GUNICORN_CMD_ARGS="--worker-tmp-dir /dev/shm" \
    PIP_USER="true"

RUN apt-get update \
    && apt-get install --no-install-recommends -yqq apt-utils >/dev/null 2>&1 \
    && apt-get install -y --no-install-recommends curl gnupg2 \
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

COPY scripts/docker/install_mysql.sh /scripts/docker/install_mssql.sh /scripts/docker/
RUN chmod a+x /scripts/docker/install_mysql.sh /scripts/docker/install_mssql.sh \
    && sync \
    && /scripts/docker/install_mysql.sh prod \
    && /scripts/docker/install_mssql.sh \
    && adduser --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password \
       --quiet "airflow" --uid "${AIRFLOW_UID}" --gid "0" --home "${AIRFLOW_USER_HOME_DIR}" \
    && mkdir -pv "${AIRFLOW_HOME}" \
    && mkdir -pv "${AIRFLOW_HOME}/dags" \
    && mkdir -pv "${AIRFLOW_HOME}/logs" \
    && chown -R airflow:0 "${AIRFLOW_USER_HOME_DIR}" "${AIRFLOW_HOME}" \
    && chmod -R g+rw "${AIRFLOW_USER_HOME_DIR}" "${AIRFLOW_HOME}" \
    && find "${AIRFLOW_HOME}" -executable -print0 | xargs --null chmod g+x \
    && find "${AIRFLOW_USER_HOME_DIR}" -executable -print0 | xargs --null chmod g+x

COPY --chown=airflow:0 --from=airflow-build-image \
     "${AIRFLOW_USER_HOME_DIR}/.local" "${AIRFLOW_USER_HOME_DIR}/.local"
COPY --chown=airflow:0 scripts/prod/entrypoint_prod.sh /entrypoint
COPY --chown=airflow:0 scripts/prod/clean-logs.sh /clean-logs

RUN chmod a+x /entrypoint /clean-logs \
    && chmod g=u /etc/passwd \
    && chmod g+w "${AIRFLOW_USER_HOME_DIR}/.local" \
    && usermod -g 0 airflow -G 0

RUN sed --in-place=.bak "s/secure_path=\"/secure_path=\"\/.venv\/bin:/" /etc/sudoers

ENV DUMB_INIT_SETSID="1" \
    PS1="(airflow)" \
    LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6"

WORKDIR ${AIRFLOW_HOME}
EXPOSE 8080
USER ${AIRFLOW_UID}

ENV C2D_RELEASE 2.5.0

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint"]
CMD [""]
