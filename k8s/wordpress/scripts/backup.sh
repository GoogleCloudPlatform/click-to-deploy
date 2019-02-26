#!/bin/bash
#
# Copyright 2018 Google LLC
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

set -euo pipefail

backup_time="$(date +%Y%m%d-%H%M%S)"

# Set default values for flags:
sql_backup_file="wp-mysql-dump-${backup_time}.sql"
files_backup_file="wp-files-dump-${backup_time}.tar.gz"
final_backup_file="wp-backup-${backup_time}.tar.gz"

mysql_host=127.0.0.1
mysql_port=3306

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
    --backup-file)
      final_backup_file="$2"
      echo "- backup-file: ${final_backup_file}"
      shift 2
      ;;
    --mysql-host)
      mysql_host="$2"
      echo "- mysql-host: ${mysql_host}"
      shift 2
      ;;
    --mysql-port)
      mysql_port="$2"
      echo "- mysql-port: ${mysql_port}"
      shift 2
      ;;
    *)
      echo "Unsupported flag: $1 - EXIT"
      exit 1
  esac
done;

remote_backup_dir="/var/wp-backup"
remote_backup_file="${remote_backup_dir}/${files_backup_file}"
wordpress_pod0_name="${app}-wordpress-0"

# Check if required flags were provided:
for var in app namespace; do
  if ! [[ -v "${var}" ]]; then
    echo "Missing flag --${var} - EXIT"
    exit 1
  fi
done

# Read wordpress database password from secret:
readonly wordpress_db_password="$(kubectl get secret -n ${namespace} ${app}-mysql-secret \
  -o jsonpath='{.data.wp-password}' \
  | base64 -d)"

# Run in background:
# run kubectl port-forward pod/${app}-mysql-0 3306 -n $NAMESPACE

local_backup_dir="/tmp/wp-backup-${backup_time}"
mkdir -p "${local_backup_dir}"

echo "Creating mysql dump file..."
mysqldump --host 127.0.0.1 -P 3306 \
  -u wordpress -p"${wordpress_db_password}" \
  --databases wordpress > "${local_backup_dir}/${sql_backup_file}"

echo "Creating remote backup of wordpress files..."
kubectl exec "${wordpress_pod0_name}" -n "${namespace}" -c wordpress \
  -- /bin/bash -c "\
     mkdir -p ${remote_backup_dir} && \
     cd ${remote_backup_dir} && \
     tar -zcvf ${files_backup_file} -C /var/www/html . && \
     md5sum ${files_backup_file}  > ${files_backup_file}.md5"

cd "${local_backup_dir}"

echo "${backup_time}" > backup_version

echo "Downloading wordpress files backup from remote pod..."
kubectl cp -n "${namespace}" "${wordpress_pod0_name}:${remote_backup_file}" \
  "${files_backup_file}"
kubectl cp -n "${namespace}" "${wordpress_pod0_name}:${remote_backup_file}.md5" \
  "${files_backup_file}.md5"

echo "Verifying local copy of files dump..."
md5sum -c "${files_backup_file}.md5"

cd -

tar -zcvf "${final_backup_file}" -C "${local_backup_dir}" .

echo "Removing remote backup files..."
kubectl exec ${app}-wordpress-0 -n ${namespace} -c wordpress \
  -- /bin/bash -c "rm ${remote_backup_file} ${remote_backup_file}.md5"

echo "Done. Backup files stored in: ${final_backup_file}."
