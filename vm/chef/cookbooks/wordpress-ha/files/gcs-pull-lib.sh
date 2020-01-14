#!/bin/bash -eu
#
# Copyright 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# GCS bucket structure:
# - app - directory containing WordPress application files;
#         created and modified only by the administrative node,
# - wp_bucket_lock - a file indicating that admin node is currently
#         writing changes to app directory,
# - wp_app_version.md5 - md5 checksum of the wp_app_version files.
#
# Operations made by content node:
# 1. Regularly compare the md5 checksum of the locally synchronized version of
#    WP app files with the remote checksum.
# 2. If change is detected:
#   a. check if bucket is unlocked (if not - skip),
#   b. rsync-in remote files.

source /opt/c2d/c2d-utils || exit 1

readonly bucket_name="$(get_attribute_value "bucket-name")"

# Constants:
readonly bucket_url="gs://${bucket_name}"

readonly local_bucket_version_file_md5="/var/www/wp_app_version.md5"
readonly remote_bucket_version_file_md5="${bucket_url}/wp_app_version.md5"

readonly remote_bucket_lock_file="${bucket_url}/wp_bucket.lock"

readonly local_app_dir="/var/www/html/"
readonly remote_app_dir="${bucket_url}/wp-app/"


# Local pull process lock operations:
# (prevent more than one sync in operation being run at once)
function lock_pull_process() {
  touch /tmp/gcs_pull.lock
}

function unlock_pull_process() {
  rm -f /tmp/gcs_pull.lock
}

function is_pull_process_locked() {
  [[ -f /tmp/gcs_pull.lock ]]
}


# Bucket lock operations:
# (prevent new readers from starting reading data while they are changed)
function is_bucket_locked() {
  gsutil -q stat "${remote_bucket_lock_file}"
}


# Sync operations
function sync_in_bucket_files() {
  gsutil -m rsync -R -p -d "${remote_app_dir}" "${local_app_dir}"
  gsutil cp "${remote_bucket_version_file_md5}" "${local_bucket_version_file_md5}"
}

function pull() {
  if is_pull_process_locked; then
    echo 'GCS sync: Ongoing pull detected. Skipping this pull sequence...'
    return 1
  fi
  if is_bucket_locked; then
    echo 'GCS sync: Bucket locked. Skipping this pull sequence...'
    return 2
  fi

  echo 'GCS sync: starting pull'
  lock_pull_process
  sync_in_bucket_files
  unlock_pull_process
  chown -Rf www-data:www-data "${local_app_dir}"
}

function pull_if_changed() {
  if [[ -f "${local_bucket_version_file_md5}" ]]; then
    local -r local_version="$(cat "${local_bucket_version_file_md5}")"
  else
    local -r local_version="0"
  fi

  if gsutil cp \
    "${remote_bucket_version_file_md5}" \
    "${local_bucket_version_file_md5}.remote"; then
    cp "${local_bucket_version_file_md5}.remote" \
      "${local_bucket_version_file_md5}.remote.$(date +%s)"
    local -r remote_version="$(cat "${local_bucket_version_file_md5}.remote")"
  else
    echo "GCS sync: remote file not available yet - skipping"
    return 0
  fi

  echo "GCS sync: local ${local_version} vs remote ${remote_version}"
  if [[ "${local_version}" != "${remote_version}" ]]; then
    echo "GCS sync: update available - running update"
    pull
  else
    echo "GCS sync: no updates available - skip..."
  fi
}
