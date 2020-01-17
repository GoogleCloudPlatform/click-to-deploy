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

source /opt/c2d/downloads/gcs-pull-lib.sh || exit 1

unlock_pull_process
gsutil -m rsync -R -p -d "${remote_app_dir}" "${local_app_dir}"
