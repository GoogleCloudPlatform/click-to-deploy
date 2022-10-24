#!/bin/bash

declare -r command="$1"
declare -r dev_image="argo-workflow3:3.4"
declare -r test_image="gcr.io/ccm-ops-test-adhoc/${dev_image}"

docker build -t "${dev_image}" 3/debian11/controller/3.4/

if [[ "${command}" == "push" ]]; then
  docker tag "${dev_image}" "${test_image}"
  docker push "${test_image}"
fi
