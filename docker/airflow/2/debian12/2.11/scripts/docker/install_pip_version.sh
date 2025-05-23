#!/usr/bin/env bash

: "${AIRFLOW_PIP_VERSION:?Should be set}"

function install_pip_version() {
    echo
    echo "Installing pip version ${AIRFLOW_PIP_VERSION}"
    echo
    pip install --disable-pip-version-check --no-cache-dir --upgrade "pip==${AIRFLOW_PIP_VERSION}"
    # Usunięto linię tworzącą folder .local/bin, ponieważ może to być zbędne w środowisku wirtualnym
}

install_pip_version