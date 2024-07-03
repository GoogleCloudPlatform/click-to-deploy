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
    --table)
      table="$2"
      echo "- table: ${table}"
      shift 2
      ;;
    *)
      echo "Unsupported flag: $1 - EXIT"
      exit 1
  esac
done;

remote_backup_dir="/tmp"
crate_master_name="${app}-crate-0"

# Check if required flags were provided:
for var in app namespace table; do
  if ! [[ -v "${var}" ]]; then
    echo "Missing flag --${var} - EXIT"
    exit 1
  fi
done

local_backup_dir="/tmp/crate"

echo "Restoring ${table} from provided backup..."
kubectl cp -n "${namespace}" "${local_backup_dir}" "${crate_master_name}:${remote_backup_dir}"
kubectl exec "${crate_master_name}" -n "${namespace}" \
  -- /bin/bash -c "\
     crash -c \"COPY ${table} FROM '/tmp/${table}_*_.json'\""

echo "Table ${table} was successfully restored."
echo "Done."
