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

backup_time="$(date +%Y%m%d-%H%M%S)"

# Set default values for flags:
sql_backup_file="mediawiki-mysql-dump-${backup_time}.sql"
files_backup_file="mediawiki-files-dump-${backup_time}.tar.gz"
final_backup_file="mediawiki-backup-${backup_time}.tar.gz"

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

remote_backup_dir="/var/mediawiki-backup"
remote_backup_file="${remote_backup_dir}/${files_backup_file}"
mediawiki_pod0_name="${app}-mediawiki-0"

# Check if required flags were provided:
for var in app namespace; do
  if ! [[ -v "${var}" ]]; then
    echo "Missing flag --${var} - EXIT"
    exit 1
  fi
done

# Read mediawiki database secrets:
readonly mediawiki_db_name="${db_name}"
readonly mediawiki_db_username="$(kubectl get secret -n ${namespace} ${app}-mysql-secret \
  -o jsonpath='{.data.mediawiki-password}' \
  | base64 -d)"
readonly mediawiki_db_password="$(kubectl get secret -n ${namespace} ${app}-mysql-secret \
  -o jsonpath='{.data.mediawiki-password}' \
  | base64 -d)"

local_backup_dir="/tmp/mediawiki-backup-${backup_time}"
mkdir -p "${local_backup_dir}"

echo "Creating mysql dump file..."
mysqldump --host "${mysql_host}" -P "${mysql_port}" \
  -u "${mediawiki_db_username}" -p"${mediawiki_db_password}" \
  --databases "${mediawiki_db_name}" > "${local_backup_dir}/${sql_backup_file}"

echo "Creating remote backup of mediawiki files..."
kubectl exec "${mediawiki_pod0_name}" -n "${namespace}" -c mediawiki \
  -- /bin/bash -c "\
     mkdir -p ${remote_backup_dir} && \
     cd ${remote_backup_dir} && \
     tar -zcvf ${files_backup_file} -C /var/www/html . && \
     md5sum ${files_backup_file}  > ${files_backup_file}.md5"

cd "${local_backup_dir}"

echo "${backup_time}" > backup_version

echo "Downloading mediawiki files backup from remote pod..."
kubectl cp -n "${namespace}" "${mediawiki_pod0_name}:${remote_backup_file}" \
  "${files_backup_file}"
kubectl cp -n "${namespace}" "${mediawiki_pod0_name}:${remote_backup_file}.md5" \
  "${files_backup_file}.md5"

echo "Verifying local copy of files dump..."
md5sum -c "${files_backup_file}.md5"

cd -

tar -zcvf "${final_backup_file}" -C "${local_backup_dir}" .

echo "Removing remote backup files..."
kubectl exec "${app}-mediawiki-0" -n "${namespace}" -c mediawiki \
  -- /bin/bash -c "rm ${remote_backup_file} ${remote_backup_file}.md5"

echo "Done. Backup files stored in: ${final_backup_file}."
