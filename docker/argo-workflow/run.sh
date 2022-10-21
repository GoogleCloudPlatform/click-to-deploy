#!/bin/bash

declare -r UNIQUE="$RANDOM"

docker run -d --name "controller-${UNIQUE}" --entrypoint sleep argo-workflow-controller3:3.4 3600
