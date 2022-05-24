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
    pip install --upgrade --upgrade-strategy only-if-needed "${AIRFLOW_INSTALLATION_METHOD}[${AIRFLOW_EXTRAS}]==${AIRFLOW_VERSION}" airflow-exporter 
}

install_airflow
