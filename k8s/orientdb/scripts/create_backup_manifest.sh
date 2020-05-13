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

## Set DATABASE to "all" to backup all databases available seperately
## Or set to database name that you want to backup
## Default is "all"
export DATABASE=${DATABASE:-all}
export NAMESPACE=${NAMESPACE:-default}

HELP_MESSAGE="# Set mandatory variables like below:
export APP_INSTANCE_NAME=orientdb-1

# Optional:
export NAMESPACE=mynamespace # default is 'default'

# Set DATABASE=all to backup all available databases
# or set single database name DATABASE=demoDB
# default is 'all'
export DATABASE=newDB

# To show help message, run:
$0 help
"

BACKUP_PROCEDURE="${APP_INSTANCE_NAME}-backup-${DATABASE}-job.yaml file was created!

#####
Next steps to backup database:

1. Scale down statefulset to 0
   WARNING: It will stop all running database nodes.

   $ kubectl -n ${NAMESPACE} scale statefulset ${APP_INSTANCE_NAME}-orientdb --replicas=0

2. Create Backup job:

   $ kubectl apply -f ${APP_INSTANCE_NAME}-backup-${DATABASE}-job.yaml

3. Check if job status is Completed:

   $ kubectl -n ${NAMESPACE} get pods -l job-name=${APP_INSTANCE_NAME}-backup-job

4. After Completion scale back OrientDB statefulset back to same replica size
   $ kubectl -n ${NAMESPACE} scale statefulset ${APP_INSTANCE_NAME}-orientdb --replicas=3

#####
To see all available backup files on first node, run:

   $ kubectl -n ${NAMESPACE} exec -it ${APP_INSTANCE_NAME}-orientdb-0 -- bash -c 'ls /orientdb/backup/'
"

# Ensure all required variables are provided.
if [ -z "${APP_INSTANCE_NAME}" ] || [[ $1 == "help" ]]; then
    echo "${HELP_MESSAGE}"
else
    envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < \
        templates/backup-job.template > ${APP_INSTANCE_NAME}-backup-${DATABASE}-job.yaml
    if [[ $? == '0' ]]; then
        echo "${BACKUP_PROCEDURE}"
    fi
fi
