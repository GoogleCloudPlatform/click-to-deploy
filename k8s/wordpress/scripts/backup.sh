#!/bin/bash

set -euo pipefail

readonly backup_time="$(date +%Y%m%d-%H%M%S)"

# Set default values for flags:
sql_backup_file="wp-mysql-dump-${backup_time}.sql"
files_backup_file="wp-files-dump-${backup_time}.tar.gz"
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
    --sql-backup-file)
      sql_backup_file="$2"
      echo "- sql-backup-file: ${sql_backup_file}"
      shift 2
      ;;
    --files-backup-file)
      files_backup_file="$2"
      echo "- files-backup-file: ${files_backup_file}"
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
remote_backup_file="${remote_backup_dir}/wp-files-dump-${backup_time}.tar.gz"
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
  -o jsonpath='{.data.wp_password}' \
  | base64 -d)"

# Run in background:
# run kubectl port-forward pod/${app}-mysql-0 3306 -n $NAMESPACE

echo "Creating mysql dump file..."
mysqldump --host 127.0.0.1 -P 3306 \
  -u wordpress -p"${wordpress_db_password}" \
  --databases wordpress > "${sql_backup_file}"

echo "Creating remote backup of wordpress files..."
kubectl exec ${app}-wordpress-0 -n ${namespace} -c wordpress \
  -- /bin/bash -c "\
     mkdir -p ${remote_backup_dir} && \
     tar -zcvf ${remote_backup_file} /var/www/html && \
     cat ${remote_backup_file} | md5sum - > ${remote_backup_file}.md5"

echo "Downloading wordpress files backup from remote pod..."
kubectl cp "${wordpress_pod0_name}:${remote_backup_file}" "${files_backup_file}" \
  -n "${namespace}"
kubectl cp "${wordpress_pod0_name}:${remote_backup_file}.md5" "${files_backup_file}.md5" \
  -n "${namespace}"

echo "Verifying local copy of files dump..."
cat "${files_backup_file}" | md5sum -c "${files_backup_file}.md5"

echo "Removing remote backup files..."
kubectl exec ${app}-wordpress-0 -n ${namespace} -c wordpress \
  -- /bin/bash -c "rm ${remote_backup_file} ${remote_backup_file}.md5"

echo "Backup files stored in:"
echo "- sql: ${sql_backup_file}"
echo "- files: ${files_backup_file}"
echo "Done."