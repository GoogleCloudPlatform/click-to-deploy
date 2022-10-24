#!/bin/bash

if [[ "${MODE}" == "controller" ]]; then
  workflow-controller "$@"
elif [[ "${MODE}" == "cli" ]]; then
  argo "$@"
else
  echo "Invalid mode."
  exit 1
fi
