#!/bin/bash

declare -r command="$1"

export APP_INSTANCE_NAME="argo-workflow-1"
export REPO="gcr.io/ccm-ops-test-adhoc/argo-workflow3"
export TAG="3.4"
export IMAGE_POSTGRESQL="marketplace.gcr.io/google/postgresql14"
export IMAGE_POSTGRESQL_EXPORTER="marketplace.gcr.io/google/postgresql-exporter0"
export POSTGRES_PASSWORD="dbpass1234"

helm template "${APP_INSTANCE_NAME}" "chart/argo-workflows/" \
  --set "argo_workflows.server.image.repo=${REPO}" \
  --set "argo_workflows.server.image.tag=${TAG}" \
  --set "argo_workflows.controller.image.repo=${REPO}" \
  --set "argo_workflows.controller.image.tag=${TAG}" \
  --set "argo_workflows.db.password=${POSTGRES_PASSWORD}" \
  --set "postgresql.image=${IMAGE_POSTGRESQL}" \
  --set "postgresql.exporter.image=${IMAGE_POSTGRESQL_EXPORTER}" \
  --set "postgresql.password=${POSTGRES_PASSWORD}" \
  | tee "${APP_INSTANCE_NAME}.yaml"

if [[ "${command}" != "dry-run" ]]; then
  kubectl apply -f "${APP_INSTANCE_NAME}.yaml"
fi
