#!/usr/bin/env bash

set -euo pipefail
declare -a packages

MYSQL_VERSION="8.0"
readonly MYSQL_VERSION

: "${INSTALL_MYSQL_CLIENT:?Should be true or false}"

install_mysql_client() {
    echo
    echo "Installing mysql client version ${MYSQL_VERSION}"
    echo

    if [[ "${1}" == "dev" ]]; then
        packages=("libmysqlclient-dev" "mysql-client")
    elif [[ "${1}" == "prod" ]]; then
        packages=("libmysqlclient21" "mysql-client")
    else
        echo
        echo "Specify either prod or dev"
        echo
        exit 1
    fi

    local key="B7B3B788A8D3785C"
    readonly key

    GNUPGHOME="$(mktemp -d)"
    export GNUPGHOME
    set +e
    for keyserver in $(shuf -e ha.pool.sks-keyservers.net hkp://p80.pool.sks-keyservers.net:80 \
                               keyserver.ubuntu.com hkp://keyserver.ubuntu.com:80)
    do
        gpg --keyserver "${keyserver}" --recv-keys "${key}" 2>&1 && break
    done
    set -e
    gpg --export "${key}" > /etc/apt/trusted.gpg.d/mysql.gpg
    gpgconf --kill all
    rm -rf "${GNUPGHOME}"
    unset GNUPGHOME
    echo "deb http://repo.mysql.com/apt/debian/ bookworm mysql-${MYSQL_VERSION}" | tee -a /etc/apt/sources.list.d/mysql.list
    apt-get update
    apt-get install --no-install-recommends -y "${packages[@]}"
    apt-get autoremove -yqq --purge
    apt-get clean && rm -rf /var/lib/apt/lists/*
}

# Install MySQL client from Oracle repositories (Debian installs mariadb)
# But only if it is not disabled
if [[ ${INSTALL_MYSQL_CLIENT:="true"} == "true" ]]; then
    install_mysql_client "${@}"
fi
