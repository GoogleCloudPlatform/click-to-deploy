#!/bin/bash

declare -r UNIQUE="$RANDOM"

# docker run -d --name "controller-${UNIQUE}" --entrypoint sleep argo-workflow-controller3:3.4 3600

docker run --rm --name "controller-${UNIQUE}" \
  -e "MODE=controller" \
  argo-workflow-controller3:3.4 version

docker run --rm --name "server-${UNIQUE}" \
  -e "MODE=cli" \
  argo-workflow-controller3:3.4 version
