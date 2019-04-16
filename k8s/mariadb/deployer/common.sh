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

create_secret() {
    APP_INSTANCE_NAME=$1
    NAMESPACE=$2

    TMP_DIR=$(mktemp -d)
    PRIMARY_DIR="${TMP_DIR}/primary"
    SECONDARY_DIR="${TMP_DIR}/secondary"

    mkdir -p ${PRIMARY_DIR} ${SECONDARY_DIR}

    # creating Certificate Authority Files
    openssl genrsa 2048 > ${TMP_DIR}/ca.key
    openssl req -new -x509 -nodes -days 365 -key ${TMP_DIR}/ca.key -out ${TMP_DIR}/ca.crt -subj "/CN=ca-mariadb/O=mariadb"

    # creating certificate for primary server
    openssl req -newkey rsa:2048 -days 365 -nodes -keyout ${PRIMARY_DIR}/tls.key -out ${PRIMARY_DIR}/tls.csr -subj "/CN=mariadb/O=mariadb"
    openssl rsa -in ${PRIMARY_DIR}/tls.key -out ${PRIMARY_DIR}/tls.key
    openssl x509 -req -in ${PRIMARY_DIR}/tls.csr -days 365 \
          -CA ${TMP_DIR}/ca.crt -CAkey ${TMP_DIR}/ca.key -set_serial 01 \
          -out ${PRIMARY_DIR}/tls.crt

    # creating certificate for secondary servers
    openssl req -newkey rsa:2048 -days 365 -nodes -keyout ${SECONDARY_DIR}/tls.key -out ${SECONDARY_DIR}/tls.csr -subj "/CN=mariadb/O=mariadb"
    openssl rsa -in ${SECONDARY_DIR}/tls.key -out ${SECONDARY_DIR}/tls.key
    openssl x509 -req -in ${SECONDARY_DIR}/tls.csr -days 365 \
          -CA ${TMP_DIR}/ca.crt -CAkey ${TMP_DIR}/ca.key -set_serial 02 \
          -out ${SECONDARY_DIR}/tls.crt

    # verify certificates
    openssl verify -CAfile ${TMP_DIR}/ca.crt ${PRIMARY_DIR}/tls.crt ${SECONDARY_DIR}/tls.crt

    # delete secrets if exist
    kubectl delete secrets -l app.kubernetes.io/component=mariadb-tls
    # create secrets
    kubectl --namespace ${NAMESPACE} create secret tls ${APP_INSTANCE_NAME}-tls --cert=${PRIMARY_DIR}/tls.crt --key=${PRIMARY_DIR}/tls.key
    kubectl --namespace ${NAMESPACE} create secret tls ${APP_INSTANCE_NAME}-secondary-tls --cert=${SECONDARY_DIR}/tls.crt --key=${SECONDARY_DIR}/tls.key
    kubectl --namespace ${NAMESPACE} create secret generic ${APP_INSTANCE_NAME}-ca-tls --from-file=${TMP_DIR}/ca.crt

    # label secrets
    for SECRET_NAME in ${APP_INSTANCE_NAME}-tls ${APP_INSTANCE_NAME}-secondary-tls ${APP_INSTANCE_NAME}-ca-tls
    do
        kubectl --namespace ${NAMESPACE} label secret ${SECRET_NAME} \
            app.kubernetes.io/name=${APP_INSTANCE_NAME} app.kubernetes.io/component=mariadb-tls
    done
}

patch_secret() {
    APP_INSTANCE_NAME=$1
    NAMESPACE=$2
    APPLICATION_UID=$(kubectl get applications/${APP_INSTANCE_NAME} --namespace=${NAMESPACE} --output=jsonpath='{.metadata.uid}')

    for SECRET_NAME in ${APP_INSTANCE_NAME}-tls ${APP_INSTANCE_NAME}-secondary-tls ${APP_INSTANCE_NAME}-ca-tls
    do
        kubectl --namespace=${NAMESPACE} patch secret ${SECRET_NAME} -p \
        '
        {
          "metadata": {
            "ownerReferences": [
              {
                "apiVersion":"app.k8s.io/v1beta1",
                "blockOwnerDeletion":true,
                "kind":"Application",
                "name":"'"${APP_INSTANCE_NAME}"'",
                "uid":"'"${APPLICATION_UID}"'"
              }
            ]
          }
        }
        '
    done
}
