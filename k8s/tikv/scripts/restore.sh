#!/bin/bash
#
# Copyright 2022 Google LLC
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

set -exuo pipefail

# Set BR version
br_version=6.1.0

while [[ "$#" != 0 ]]; do
  case "$1" in
    --app)
      app="$2"
      echo "- app: ${app}"
      shift 2
      ;;
    --namespace)
      namespace="$2"
      echo "- namespace: ${namespace}"
      shift 2
      ;;
    --backup-dir)
      backup_dir="$2"
      echo "- backup-dir: ${backup_dir}"
      shift 2
      ;;
    *)
      echo "Unsupported flag: $1 - EXIT"
      exit 1
  esac
done;

# Check if required flags were provided:
for var in app namespace backup_dir; do
  if ! [[ -v "${var}" ]]; then
    echo "Missing flag --${var} - EXIT"
    exit 1
  fi
done

remote_backup_dir="/tmp"
tikv_pd_pod0_name="${app}-pd-0"

echo "Restoring database from provided backup..."
kubectl cp -n "${namespace}" "${backup_dir}" "${tikv_pd_pod0_name}:${remote_backup_dir}"
kubectl exec "${tikv_pd_pod0_name}" -n "${namespace}" \
  -- /bin/bash -c "\
     curl -L https://download.pingcap.org/tidb-community-toolkit-v${br_version}-linux-amd64.tar.gz -o /tidb.tar.gz && \\
     tar xvf /tidb.tar.gz tidb-community-toolkit-v${br_version}-linux-amd64/br-v${br_version}-linux-amd64.tar.gz && \
     tar xvf tidb-community-toolkit-v${br_version}-linux-amd64/br-v${br_version}-linux-amd64.tar.gz --directory / && \
     /br restore raw --pd "localhost:2379" -s "local://${remote_backup_dir}" --cf default"

echo "Backup from ${backup_dir} successfully restored."
echo "Done."
