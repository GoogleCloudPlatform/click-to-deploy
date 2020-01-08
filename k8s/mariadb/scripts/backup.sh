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
This script creates a backup files from MariaDB cluster
Usage: $0 [OPTION...]

Parameters:
-a, --app_instance_name     (Optional) Name of application in K8s cluster
                            default is "mariadb"
-n, --namespace             (Optional) Name of K8s namespace, where MariaDB
                            cluster exists
-o, --output                (Optional) Target backup file location,
                            defaults to current directory

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
    -o|--output)
        OUTPUT_DIR="$2"
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
PRIMARY=${APP_INSTANCE_NAME}-mariadb-0
BKP_DIR=/var/mariadb/backup
BKP_NAME="all-databases-$(date +%Y-%m-%d).sql"
OUTPUT=${OUTPUT_DIR:-.}/${BKP_NAME}

kubectl -n ${NAMESPACE} exec -it ${PRIMARY} -- sh -c "mkdir -p ${BKP_DIR} && \
    mysqldump --all-databases --add-drop-database --add-drop-table --single-transaction -uroot -p\${MYSQL_ROOT_PASSWORD} \
    > ${BKP_DIR}/${BKP_NAME}"

kubectl cp ${NAMESPACE}/${PRIMARY}:${BKP_DIR}/${BKP_NAME} ${OUTPUT}
kubectl -n ${NAMESPACE} exec -it ${PRIMARY} -- sh -c "rm -f ${BKP_DIR}/${BKP_NAME}"
