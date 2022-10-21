#!/bin/bash

gcloud beta builds submit \
  --project cloud-marketplace-ops-test \
  --substitutions=_GH_TOKEN=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 \
  --config cloudbuild-docker-dispatcher.yaml
