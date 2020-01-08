#!/bin/bash
#
# Copyright 2019 Google LLC
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

# Set default values for flags:
mysql_host=127.0.0.1
mysql_port=3306
db_name="mediawiki"

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
    --db-name)
      db_name="$2"
      echo "- db-name: ${db_name}"
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
readonly root_db_password="$(kubectl get secret -n ${namespace} ${app}-mysql-secret \
  -o jsonpath='{.data.root-password}' \
  | base64 -d)"

# Read mediawiki database secrets:
readonly mediawiki_db_name="${db_name}"
readonly mediawiki_db_username="$(kubectl get secret -n ${namespace} ${app}-mysql-secret \
  -o jsonpath='{.data.mediawiki-username}' \
  | base64 -d)"
readonly mediawiki_db_password="$(kubectl get secret -n ${namespace} ${app}-mysql-secret \
  -o jsonpath='{.data.mediawiki-password}' \
  | base64 -d)"

echo "Unpacking the provided backup archive..."
backup_dir="/tmp/mediawiki-backup-$(date +%s)"
mkdir -p "${backup_dir}"
tar xvf "${backup_file}" -C "${backup_dir}"

cd "${backup_dir}"
backup_version="$(cat backup_version)"
sql_dump_file="mediawiki-mysql-dump-${backup_version}.sql"
files_dump_file="mediawiki-files-dump-${backup_version}.tar.gz"

echo "Backup version found: ${backup_version}..."

restore_time="$(date +%Y%m%d_%H%M%S)"
mediawiki_database_backup="mediawiki_${restore_time}"

echo "Creating current mediawiki database backup - ${mediawiki_database_backup}..."
echo "
  CREATE DATABASE IF NOT EXISTS \`${mediawiki_database_backup}\`;
  GRANT ALL ON \`${mediawiki_database_backup}\`.* TO '${mediawiki_db_username}'@'%';
  FLUSH PRIVILEGES" | \
  mysql -u root -p"${root_db_password}" -h "${mysql_host}" -P "${mysql_port}"

echo "Moving tables from current mediawiki database to its backup..."
mysql -h "${mysql_host}" -P "${mysql_port}" \
  -u "${mediawiki_db_username}" -p"${mediawiki_db_password}" \
  "${mediawiki_db_name}" -sNe 'show tables' \
  | while read table; do \
    echo "Moving table ${table}..."
    mysql -h "${mysql_host}" -P "${mysql_port}" \
      -u "${mediawiki_db_username}" -p"${mediawiki_db_password}" \
      ${mediawiki_db_name} \
      -sNe "RENAME TABLE \`${mediawiki_db_name}\`.\`${table}\` TO \`${mediawiki_database_backup}\`.\`${table}\`"; \
  done

echo "Restoring database from provided backup..."
mysql -h "${mysql_host}" -P "${mysql_port}" \
  -u "${mediawiki_db_username}" -p"${mediawiki_db_password}" \
  "${mediawiki_db_name}" < "${sql_dump_file}"

remote_backup_dir="/var/mediawiki-backup"
remote_restore_dir="/var/mediawiki-restore"
mediawiki_files_backup="mediawiki-files-${restore_time}.tar.gz"
mediawiki_pod0_name="${app}-mediawiki-0"

echo "Creating remote backup of current mediawiki files..."
kubectl exec "${mediawiki_pod0_name}" -n "${namespace}" -c mediawiki \
  -- /bin/bash -c "\
     mkdir -p ${remote_backup_dir} && \
     mkdir -p ${remote_restore_dir} && \
     cd ${remote_backup_dir} && \
     tar -zcvf ${mediawiki_files_backup} -C /var/www/html . && \
     rm -rf /var/www/html/*"

echo "Copying files backup version ${backup_version} to restore..."
kubectl cp -n "${namespace}" "${files_dump_file}" \
  "${mediawiki_pod0_name}:${remote_restore_dir}/${files_dump_file}"
kubectl cp -n "${namespace}" "${files_dump_file}.md5" \
  "${mediawiki_pod0_name}:${remote_restore_dir}/${files_dump_file}.md5"

echo "Verifying remote copy of files backup..."
kubectl exec "${app}-mediawiki-0" -n "${namespace}" -c mediawiki \
  -- /bin/bash -c "cd ${remote_restore_dir} && md5sum -c ${files_dump_file}.md5"

echo "Unpacking mediawiki files from backup..."
kubectl exec "${mediawiki_pod0_name}" -n "${namespace}" -c mediawiki \
  -- /bin/bash -c "tar xvf ${remote_restore_dir}/${files_dump_file} -C /var/www/html"

echo "Removing remote backup archive fore version ${backup_version}..."
kubectl exec "${mediawiki_pod0_name}" -n "${namespace}" -c mediawiki \
  -- /bin/bash -c "\
     cd ${remote_restore_dir} && \
     rm ${files_dump_file} && \
     rm ${files_dump_file}.md5"

echo "Backup of version ${backup_version} successfully restored."
echo "Original data are saved in database: ${mediawiki_database_backup}."
echo "Original files are saved in archive ${remote_backup_dir}/${mediawiki_files_backup}."
echo "Done."
