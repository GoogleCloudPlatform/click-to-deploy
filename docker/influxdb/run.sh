#!/bin/bash

declare -r version="$1"
declare -r image_name="influxdb2:${version}"
declare -r command="$2"

# Build
if [[ "${command}" == "build" ]]; then
  docker build -t "${image_name}" "2/debian11/${version}/"
fi

# Test
if [[ "${command}" == "test" ]]; then
  docker run --rm -it \
    -v $PWD/tests/functional_tests:/functional_tests:ro \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gcr.io/cloud-marketplace-ops-test/functional_test \
      --verbose \
      --vars UNIQUE=$RANDOM \
      --vars IMAGE="${image_name}" \
      --test_spec /functional_tests/influx_smoke_test.yaml
fi
