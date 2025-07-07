#!/usr/bin/env bash

: "${AIRFLOW_PIP_VERSION:?Should be set}"

function install_airflow() {
    # Remove mysql from extras if client is not going to be installed
    if [[ ${INSTALL_MYSQL_CLIENT} != "true" ]]; then
        AIRFLOW_EXTRAS=${AIRFLOW_EXTRAS/mysql,}
    fi
    echo
    echo "Installing all packages and upgrade if needed"
    echo

    # https://airflow.apache.org/docs/apache-airflow/stable/installation/installing-from-pypi.html
    # https://github.com/apache/airflow/issues/36883
    set -x
    PY_MAJOR_VERSION="$(python3 -V | grep -o -P "\d+\.\d+")"
    CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}-fix/constraints-${PY_MAJOR_VERSION}.txt"

    pip install \
        --constraint "${CONSTRAINT_URL}" \
        --upgrade \
        --upgrade-strategy only-if-needed "${AIRFLOW_INSTALLATION_METHOD}[${AIRFLOW_EXTRAS}]==${AIRFLOW_VERSION}" airflow-exporter
    pip install apache-airflow-providers-cncf-kubernetes
}

install_airflow
