#!/bin/bash
#
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

usage () {
cat << EOF
This script restores MariaDB cluster data
Usage: $0 [OPTION...]

Parameters:
-f, --file                  Target backup file location,
-a, --app_instance_name     (Optional) Name of application in K8s cluster
                            default is "mariadb"
-n, --namespace             (Optional) Name of K8s namespace, where MariaDB
                            cluster exists

Example:
$0 -a mariadb-1 -n custom-namespace -o custom/file.sql
EOF
}

for key in "$@"
do
case $key in
    -h|--help)
        usage
        exit 0
        ;;
    -a|--app_instance_name)
        APP_INSTANCE_NAME="$2"
        shift 2
        ;;
    -n|--namespace)
        NAMESPACE="$2"
        shift 2
        ;;
    -f|--file)
        FILE="$2"
        shift 2
        ;;
    *)
        usage
        exit 1
        ;;
esac
done

NAMESPACE=${NAMESPACE:-default}
APP_INSTANCE_NAME=${APP_INSTANCE_NAME:-mariadb}
POD=$APP_INSTANCE_NAME-mariadb-0
BKP_DIR=/var/mariadb/backup
BKP_FILE="${BKP_DIR}/all-databases.sql"
FILE=${FILE:?"Specify backup file with -f option"}

if [[ ! -f ${FILE} ]]; then
    echo "ERROR: Backup file not found!"
    exit 1;
fi

# restore all databases from provided backup
kubectl -n ${NAMESPACE} exec -it ${POD} -- sh -c "mkdir -p ${BKP_DIR}"
kubectl cp ${FILE} ${NAMESPACE}/${POD}:${BKP_FILE}
kubectl -n ${NAMESPACE} exec -it ${POD} -- bash -c "mysql -uroot -p\${MYSQL_ROOT_PASSWORD} -e \"
        source ${BKP_FILE}; \
        SET PASSWORD = PASSWORD('\${MYSQL_ROOT_PASSWORD}');
        ALTER USER 'root'@'%' IDENTIFIED BY '\${MYSQL_ROOT_PASSWORD}'; \
        ALTER USER '\${MARIADB_REPLICATION_USER}'@'%' IDENTIFIED BY '\${MARIADB_REPLICATION_PASSWORD}'; \
        FLUSH PRIVILEGES; \" "

# cleanup
kubectl -n ${NAMESPACE} exec -it ${POD} -- sh -c "rm -f ${BKP_FILE}"
