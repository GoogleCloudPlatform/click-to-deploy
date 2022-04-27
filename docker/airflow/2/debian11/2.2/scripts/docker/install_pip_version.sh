#!/usr/bin/env bash

: "${AIRFLOW_PIP_VERSION:?Should be set}"

function install_pip_version() {
    echo
    echo "Installing pip version ${AIRFLOW_PIP_VERSION}"
    echo
    pip install --disable-pip-version-check --no-cache-dir --upgrade "pip==${AIRFLOW_PIP_VERSION}" &&
        mkdir -p ${HOME}/.local/bin
}

install_pip_version
