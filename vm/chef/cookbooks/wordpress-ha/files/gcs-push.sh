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
# - wp_app_version.json - a JSON file containing information about
#         date of last modification in any file inside the app directory
#         and a md5 checksum for the list of files,
# - wp_app_version.json.md5 - md5 checksum of the wp_app_version.json file.
#
# Operations made by admin node:
# 1. Regularly check the last modification date on the local WP app directory
#    to detect changes in existing files and calculate checksum of the list
#    of all files under the WP app directory.
# 2. If change is detected:
#    a. lock the bucket for write,
#    b. rsync-out local files,
#    c. update the remote information about last modification date
#    d. unlock the bucket.

source /opt/c2d/c2d-utils || exit 1

readonly bucket_name="$(get_attribute_value "bucket-name")"

# Constants:
readonly bucket_url="gs://${bucket_name}"

readonly local_bucket_version_file="/var/www/wp_app_version.md5"
readonly remote_bucket_version_file="${bucket_url}/wp_app_version.md5"

readonly local_bucket_lock_file="/var/www/wp_bucket.lock"
readonly remote_bucket_lock_file="${bucket_url}/wp_bucket.lock"

readonly local_app_dir="/var/www/html/"
readonly remote_app_dir="${bucket_url}/wp-app/"

readonly push_process_lock_file="/tmp/gcs_push.lock"


# Bucket files operations:
function sync_files_out_to_bucket() {
  gsutil -m rsync -R -p -d "${local_app_dir}" "${remote_app_dir}"
  gsutil cp "${local_bucket_version_file}" "${remote_bucket_version_file}"
}


# Bucket lock operations:
# (prevent new readers from starting reading data while they are changed)
function lock_bucket() {
  touch "${local_bucket_lock_file}"
  gsutil cp "${local_bucket_lock_file}" "${remote_bucket_lock_file}"
}

function unlock_bucket() {
  rm -f "${local_bucket_lock_file}"
  if ! gsutil rm -f "${remote_bucket_lock_file}"; then
    echo "GCS sync: the bucket lock file did not exist"
  fi
}

function is_bucket_locked() {
  gsutil -q stat "${remote_bucket_lock_file}"
}

# Local push process lock operations:
# (prevent more than one sync out operation being run at once):
function lock_push_process() {
  touch /tmp/gcs_push.lock
}

function unlock_push_process() {
  rm -f /tmp/gcs_push.lock
}

function is_push_process_locked() {
  [[ -f /tmp/gcs_push.lock ]]
}


# Local app version operations:
function read_bucket_version_local() {
  if [[ -f "${local_bucket_version_file}" ]]; then
    cat "${local_bucket_version_file}"
  else
    echo "0"
  fi
}

function update_bucket_version_local() {
  local -r new_sum="$1"
  echo "${new_sum}" > "${local_bucket_version_file}"
}


# Detecting local files modifications and sending them out to bucket:
function calculate_checksum_for_local_app() {
  local -r dir="$1"
  # Generate a list of all files and directories under the main app directory
  # (paths + last modification time), sort the list, calulate md5 checksum for
  # the list and return it. This way we detect files updates, creations and
  # deletions.
  find "${dir}" -printf "%P %T@\n" | sort -n | md5sum | cut -d ' ' -f 1
}

function push() {
  echo 'GCS sync: Attempting to push to GCS...'
  if is_push_process_locked; then
      echo 'GCS sync: Ongoing push detected. Skipping this push sequence...'
      return 1
  fi
  if is_bucket_locked; then
      echo 'GCS sync: Bucket locked. Skipping this push sequence...'
      return 2
  fi

  lock_push_process
  lock_bucket

  sync_files_out_to_bucket

  unlock_bucket
  unlock_push_process
}

function push_if_changed() {
  local -r curr_sum="$(calculate_checksum_for_local_app "${local_app_dir}")"
  local -r prev_sum="$(read_bucket_version_local)"
  echo "GCS sync: files checksum: ${curr_sum} vs ${prev_sum}"

  if [[ "${curr_sum}" != "${prev_sum}" ]]; then
    echo "GCS sync: change detected - syncing to bucket"
    update_bucket_version_local "${curr_sum}"
    push
  else
    echo "GCS sync: no change detected in app files - skipping"
  fi
}

# Main process:
unlock_bucket
unlock_push_process
while [[ true ]]; do
    push_if_changed
    sleep 10
done
