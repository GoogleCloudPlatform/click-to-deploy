#!/bin/bash

declare -r NAME="${RANDOM}"
declare -r IMAGE="dragonfly-manager"

docker build -t dragonfly-manager  2/debian11/dragonfly-manager/2.0/

docker run --rm -it \
  -v $PWD/tests/functional_tests:/functional_tests:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gcr.io/cloud-marketplace-ops-test/functional_test \
    --verbose \
    --vars UNIQUE="${RANDOM}" \
    --vars IMAGE="${IMAGE}" \
    --test_spec /functional_tests/running_test.yaml
