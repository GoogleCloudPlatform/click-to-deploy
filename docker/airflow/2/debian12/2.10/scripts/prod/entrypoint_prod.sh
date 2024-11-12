#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# Might be empty
set -euo pipefail

# Adding the appropriate path, if necessary
export PATH="/home/airflow/venv/bin:$PATH"

CONNECTION_CHECK_MAX_COUNT=${CONNECTION_CHECK_MAX_COUNT:=5}
CONNECTION_CHECK_SLEEP_TIME=${CONNECTION_CHECK_SLEEP_TIME:=2}

# Function that initializes the database only when necessary
function initialize_airflow_db() {
    airflow db check &>/dev/null
    if [ $? != 0 ]; then
       echo "Initializing the database..."
       airflow db init
    else
       echo "The database is already initialized."
    fi
}

# Waiting until the database is ready
function wait_for_airflow_db() {
    local retries=${CONNECTION_CHECK_MAX_COUNT}
    until airflow db check; do
        ((retries--))
        if [[ $retries -le 0 ]]; then
            echo "Failed to connect to the database after the maximum number of attempts."
            exit 1
        fi
        echo "Waiting for connection to the database..."
        sleep ${CONNECTION_CHECK_SLEEP_TIME}
    done
    echo "Connection to the database established."
}

# Updating the database schema
function upgrade_db() {
    echo "Updating the database..."
    airflow db upgrade
}

# Creating a missing system user, if necessary
function create_system_user_if_missing() {
    if ! whoami &> /dev/null; then
        if [[ -w /etc/passwd ]]; then
            echo "${AIRFLOW_USER_NAME:=airflow}:x:$(id -u):0:${USER_NAME:-Airflow User}:${AIRFLOW_HOME:=/home/airflow}:/sbin/nologin" >> /etc/passwd
        fi
        export HOME="${AIRFLOW_HOME}"
    fi
}

# Initialization functions
initialize_airflow_db
create_system_user_if_missing

if [[ "${CONNECTION_CHECK_MAX_COUNT}" -gt "0" ]]; then
    wait_for_airflow_db
fi

# Database upgrade
upgrade_db

exec "airflow" "$@"