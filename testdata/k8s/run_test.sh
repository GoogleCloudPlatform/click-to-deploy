#!/bin/bash

set -eux

function diff_manifest()
{
  local -r solution=$1
  local -r manifest=$2

  tempfile=$(mktemp /tmp/XXXXXXXXXX.yaml)
  cd ../../

  helm template "k8s/${solution}/chart/${solution}" \
    --values "testdata/k8s/${solution}/${manifest}.values.yaml" \
    > "${tempfile}"

  echo "${tempfile}"
  cd -

  diff "${solution}/${manifest}.manifest.yaml" "${tempfile}"
}

shopt -s nullglob

solution=wordpress

for value in ${solution}/*.values.yaml; do
  name=$(basename "${value}" .values.yaml)
  diff_manifest "${solution}" "${name}"
done


