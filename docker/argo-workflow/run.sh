#!/bin/bash

declare -r UNIQUE="$RANDOM"

declare -r dev_image="argo-workflow3:3.4"

docker run -d --name "controller-${UNIQUE}" --entrypoint sleep "${dev_image}" 3600

# docker run --rm --name "controller-${UNIQUE}" \
#   -e "MODE=controller" \
#   argo-workflow-controller3:3.4 version

# docker run --rm --name "server-${UNIQUE}" \
#   -e "MODE=cli" \
#   argo-workflow-controller3:3.4 version
