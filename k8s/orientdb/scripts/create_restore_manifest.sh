#!/bin/bash
#
# Copyright 2020 Google LLC
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

export NAMESPACE=${NAMESPACE:-default}

HELP_MESSAGE="# Set mandatory variables like below:

export APP_INSTANCE_NAME=orientdb-1

export DATABASE=yourDB

# RESTORE_FILE should exist inside '/orientdb/backup' directory of first node of cluster.
# To list available backup files, run:
# $ kubectl exec -it <APP_INSTANCE_NAME>-orientdb-0 -- bash -c 'ls /orientdb/backup/'

export RESTORE_FILE=yourDB-XYZ.zip

# Optional:
export NAMESPACE=mynamespace # default is 'default'

# To show help message, run:
$0 help
"

RESTORE_PROCEDURE="${APP_INSTANCE_NAME}-restore-${DATABASE}-job.yaml file was created!

#####
Before starting restore procedure:

You need to copy your backup file to ${APP_INSTANCE_NAME}-orientdb-0 inside /orientdb/backup directory:

    $ kubectl -n ${NAMESPACE} cp ${RESTORE_FILE} ${APP_INSTANCE_NAME}-orientdb-0:/orientdb/backup

To list available backup files in first node, run:

    $ kubectl -n ${NAMESPACE} exec -it ${APP_INSTANCE_NAME}-orientdb-0 -- bash -c 'ls /orientdb/backup/'

#####
Next steps to restore database:

1. Scale down statefulset to 0
   WARNING: It will stop all running database nodes.

   $ kubectl -n ${NAMESPACE} scale statefulset ${APP_INSTANCE_NAME}-orientdb --replicas=0

2. Create Restore job:

   $ kubectl apply -f ${APP_INSTANCE_NAME}-restore-${DATABASE}-job.yaml

3. Check if job status is Completed:

   $ kubectl -n ${NAMESPACE} get pods -l job-name=${APP_INSTANCE_NAME}-restore-job

4. After Completion scale back OrientDB statefulset back to same replica size
   $ kubectl -n ${NAMESPACE} scale statefulset ${APP_INSTANCE_NAME}-orientdb --replicas=3
"


if [ -z "${APP_INSTANCE_NAME}" ] || [ -z "${DATABASE}" ] || \
   [ -z "${RESTORE_FILE}" ] || [[ $1 == "help" ]]; then
    echo "${HELP_MESSAGE}"
else
    envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < \
        templates/restore-job.template > \
        ${APP_INSTANCE_NAME}-restore-${DATABASE}-job.yaml
    if [[ $? == '0' ]]; then
        echo "${RESTORE_PROCEDURE}"
    fi
fi
