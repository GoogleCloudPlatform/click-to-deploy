#!/bin/bash

PROJECT="ccm-ops-test-adhoc"

gcloud builds submit \
  --config tools/cloudbuild-dockertools.yaml \
  --project "${PROJECT}" \
  .
