#!/bin/bash
#
# Copyright 2019 Google LLC
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

set -exuo pipefail

# Set default values for flags:
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
      backup_file="$2"
      echo "- backup-file: ${backup_file}"
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

# Check if required flags were provided:
for var in app namespace backup_file; do
  if ! [[ -v "${var}" ]]; then
    echo "Missing flag --${var} - EXIT"
    exit 1
  fi
done

# Read root database password from secret:
readonly root_db_password="$(kubectl get secret -n ${namespace} ${app}-mariadb-secret \
  -o jsonpath='{.data.root-password}' \
  | base64 -d)"

# Read joomla database password from secret:
readonly joomla_db_password="$(kubectl get secret -n ${namespace} ${app}-mariadb-secret \
  -o jsonpath='{.data.joomla-password}' \
  | base64 -d)"

echo "Unpacking the provided backup archive..."
backup_dir="/tmp/joomla-backup-$(date +%s)"
mkdir -p "${backup_dir}"
tar xvf "${backup_file}" -C "${backup_dir}"

cd "${backup_dir}"
backup_version="$(cat backup_version)"
sql_dump_file="joomla-mysql-dump-${backup_version}.sql"
files_dump_file="joomla-files-dump-${backup_version}.tar.gz"

echo "Backup version found: ${backup_version}..."

restore_time="$(date +%Y%m%d_%H%M%S)"
joomla_database=joomla
joomla_database_backup="joomla_${restore_time}"

echo "Creating current joomla database backup - ${joomla_database_backup}..."
echo "
  CREATE DATABASE \`${joomla_database_backup}\`;
  GRANT ALL ON \`${joomla_database_backup}\`.* TO 'joomla'@'%';
  FLUSH PRIVILEGES" | \
  mysql -u root -p"${root_db_password}" -h "${mysql_host}" -P "${mysql_port}"

echo "Moving tables from current joomla database to its backup..."
mysql -h "${mysql_host}" -P "${mysql_port}" \
  -u joomla -p"${joomla_db_password}" \
  "${joomla_database}" -sNe 'show tables' \
  | while read table; do \
    echo "Moving table ${table}..."
    mysql -h "${mysql_host}" -P "${mysql_port}" \
      -u joomla -p"${joomla_db_password}" \
      ${joomla_database} \
      -sNe "RENAME TABLE \`${joomla_database}\`.\`${table}\` TO \`${joomla_database_backup}\`.\`${table}\`"; \
  done

echo "Restoring database from provided backup..."
mysql -h "${mysql_host}" -P "${mysql_port}" \
  -u joomla -p"${joomla_db_password}" \
  "${joomla_database}" < "${sql_dump_file}"

remote_backup_dir="/var/joomla-backup"
remote_restore_dir="/var/joomla-restore"
joomla_files_backup="joomla-files-${restore_time}.tar.gz"
joomla_pod0_name="${app}-joomla-0"

echo "Creating remote backup of current joomla files..."
kubectl exec "${joomla_pod0_name}" -n "${namespace}" -c joomla \
  -- /bin/bash -c "\
     mkdir -p ${remote_backup_dir} && \
     mkdir -p ${remote_restore_dir} && \
     cd ${remote_backup_dir} && \
     tar -zcvf ${joomla_files_backup} -C /var/www/html . && \
     rm -rf /var/www/html/*"

echo "Copying files backup version ${backup_version} to restore..."
kubectl cp -n "${namespace}" "${files_dump_file}" \
  "${joomla_pod0_name}:${remote_restore_dir}/${files_dump_file}"
kubectl cp -n "${namespace}" "${files_dump_file}.md5" \
  "${joomla_pod0_name}:${remote_restore_dir}/${files_dump_file}.md5"

echo "Verifying remote copy of files backup..."
kubectl exec "${app}-joomla-0" -n "${namespace}" -c joomla \
  -- /bin/bash -c "cd ${remote_restore_dir} && md5sum -c ${files_dump_file}.md5"

echo "Unpacking joomla files from backup..."
kubectl exec "${joomla_pod0_name}" -n "${namespace}" -c joomla \
  -- /bin/bash -c "tar xvf ${remote_restore_dir}/${files_dump_file} -C /var/www/html"

echo "Removing remote backup archive fore version ${backup_version}..."
kubectl exec "${joomla_pod0_name}" -n "${namespace}" -c joomla \
  -- /bin/bash -c "\
     cd ${remote_restore_dir} && \
     rm ${files_dump_file} && \
     rm ${files_dump_file}.md5"

echo "Backup of version ${backup_version} successfully restored."
echo "Original data are saved in database: ${joomla_database_backup}."
echo "Original files are saved in archive ${remote_backup_dir}/${joomla_files_backup}."
echo "Done."
