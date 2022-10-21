#!/bin/bash

while IFS="/" read -r app_type solution path; do
  # app_type="$(echo "${change}" | cut -d "/" -f 1)"
  # solution="$(echo "${change}" | cut -d "/" -f 2)"
  echo "(${app_type}) ${solution}"
done < changes.txt
