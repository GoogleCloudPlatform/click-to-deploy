#!/bin/bash
#
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eu

source "$(dirname "${0}")/test_util.sh"

ROOT_MD5=$(mktemp "/tmp/root.XXXXXX")
declare -r ROOT_MD5
DEBIAN_VERSION=$(cat /etc/debian_version)
declare -r DEBIAN_VERSION

# Check Debian version.
echo "Debian version: ${DEBIAN_VERSION}" # Debug print
case "${DEBIAN_VERSION}" in
  8*)
    echo "e12f5739f81b08c470f20890304bf53e /root/.bashrc" >> "${ROOT_MD5}"
    echo "54328f6b27a45c51986ed436f3f609bf /root/.profile" >> "${ROOT_MD5}"
  ;;
  9*|10*)
    echo "e12f5739f81b08c470f20890304bf53e /root/.bashrc" >> "${ROOT_MD5}"
    echo "46438b614dcb2175148fa7e0bdc604a4 /root/.profile" >> "${ROOT_MD5}"
  ;;
  11*|12*)
    echo "0a540d50c157ed0070459b82c358a05a /root/.bashrc" >> "${ROOT_MD5}"
    echo "d68ce7c7d7d2bb7d48aeb2f137b828e4 /root/.profile" >> "${ROOT_MD5}"
    # generate and add md5 for files in .ssh folder
    if [[ -d /root/.ssh && -n $(ls -A /root/.ssh) ]]; then # dodajemy sprawdzenie, czy katalog /root/.ssh istnieje i czy jest niepusty
      for file in /root/.ssh/*; do
        if [[ -f "${file}" ]]; then # dodatkowo upewniamy się, że "${file}" jest plikiem (a nie np. podkatalogiem)
          md5="$(md5sum "${file}")"
          echo "${md5}" >> "${ROOT_MD5}"
        fi
      done
    fi
  ;;
  *)
    failure_msg "Debian ${DEBIAN_VERSION} is not supported!"
  ;;
esac

# This test checks checksum of .bashrc and .profle in /root/ directory.
start_test_msg "/root/ checksum"

echo "Debian: ${DEBIAN_VERSION}"
cat "${ROOT_MD5}"

# FIND different files that $ROOT_MD5 has
for file in $(find /root/ -mindepth 1); do
  if [[ "${file}" == /root/.config* || "${file}" == /root/.gsutil* || "${file}" == /root/.ssh*   ]]; then
    echo "${file}: gcloud config. Skip."
    continue
  else
    # IF $ROOT_MD5 doesn't contains $file
    if grep -q "^[a-f0-9]\+ \+${file}$" "${ROOT_MD5}"; then
      echo "${file}: exists"
    else
      failure_msg "${file} is not expected!"
    fi
  fi
done

# # If this test fails, update the MD5 hashes above.
# # To update MD5 hashes we have to log in to an instance
# # with debian-8 or debian-9 base image
# # and execute this command as root: find /root/ -mindepth 1 | xargs md5sum
# # CHECKSUM
md5sum -c "${ROOT_MD5}" && success || failure