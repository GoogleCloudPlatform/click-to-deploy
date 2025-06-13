#!/bin/bash
#
# Copyright (C) 2019 Google LLC.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

set -e

# Enable bash debug if DEBUG_DOCKER_ENTERYPOINT exists
if [[ "${DEBUG_DOCKER_ENTRYPOINT}" = "true" ]]; then
    echo "!!! WARNING: DEBUG_DOCKER_ENTRYPOINT is enabled!"
    echo "!!! WARNING: Use only for debugging. Do not use in production!"
    set -x
    env
fi

if [[ -n ${MYSQL_PORT_3306_TCP} ]]; then
  if [[ -z ${DRUPAL_DB_HOST} ]]; then
    DRUPAL_DB_HOST='mysql'
  else
    echo >&2 "warning: both DRUPAL_DB_HOST and MYSQL_PORT_3306_TCP found"
    echo >&2 "  Connecting to DRUPAL_DB_HOST (${DRUPAL_DB_HOST})"
    echo >&2 "  instead of the linked mysql container"
  fi
fi

if [[ -z ${DRUPAL_DB_HOST} ]]; then
  echo >&2 "error: missing DRUPAL_DB_HOST and MYSQL_PORT_3306_TCP environment variables"
  echo >&2 "  Did you forget to --link some_mysql_container:mysql or set an external db"
  echo >&2 "  with -e DRUPAL_DB_HOST=hostname:port?"
  exit 1
fi

# If the DB user is 'root' then use the MySQL root password env var
: ${DRUPAL_DB_USER:=root}
if [[ ${DRUPAL_DB_USER} = 'root' ]]; then
  : ${DRUPAL_DB_PASSWORD:=${MYSQL_ENV_MYSQL_ROOT_PASSWORD}}
fi
: ${DRUPAL_DB_NAME:=drupal}

if [[ -z ${DRUPAL_DB_PASSWORD} ]]; then
  echo >&2 "error: missing required DRUPAL_DB_PASSWORD environment variable"
  echo >&2 "  Did you forget to -e DRUPAL_DB_PASSWORD=... ?"
  echo >&2
  echo >&2 "  (Also of interest might be DRUPAL_DB_USER and DRUPAL_DB_NAME.)"
  exit 1
fi

if [[ ${AUTO_INSTALL} = 'yes' ]]; then
  if [[ -z ${DRUPAL_PASSWORD} ]]; then
    echo >&2 "error: AUTO_INSTALL=yes required DRUPAL_PASSWORD environment variable"
    echo >&2 "  Did you forget to -e DRUPAL_PASSWORD=... ?"
    echo >&2
    echo >&2 "  (Also of interest might be DRUPAL_USER_NAME and DRUPAL_USER_EMAIL.)"
    exit 1
  fi
fi

# Await for MySQL server be up
timeout --preserve-status 300 bash -c "
  until echo > /dev/tcp/${DRUPAL_DB_HOST}/3306; do sleep 2; done"

# Ensure the MySQL Database is created
php /makedb.php "${DRUPAL_DB_HOST}" "${DRUPAL_DB_USER}" "${DRUPAL_DB_PASSWORD}" "${DRUPAL_DB_NAME}"

if ! [[ -e index.php && -e core/lib/Drupal.php ]]; then
  echo >&2 "Drupal not found in $(pwd) - copying now..."

  if [[ "$(ls -A)" && ${DRUPAL_NO_CHECK_VOLUME} != 'yes' ]]; then
    echo >&2 "error: $(pwd) is not empty."
    echo >&2 "  Did you forget to -e DRUPAL_NO_CHECK_VOLUME=yes ?"
    exit 1
  fi

  tar cf - --one-file-system -C /usr/src/drupal . | tar xf -
  chown -R www-data:www-data /var/www/html/{sites,modules,themes}

  echo >&2 "Complete! Drupal has been successfully copied to $(pwd)"

  # Install core module
  curl -o composer.phar "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" \
    && echo "${COMPOSER_SHA256} composer.phar" | sha256sum -c - \
    && chmod +x composer.phar \
    && php ./composer.phar install \
    && rm -f composer.phar

  if [[ ${AUTO_INSTALL} = 'yes' ]]; then
    : ${DRUPAL_USER_NAME:='admin'}
    : ${DRUPAL_USER_EMAIL:='noreply@example.com'}
    : ${DRUPAL_SITE_NAME:='C2D_Drupal_Site'}
    DRUPAL_USER_ID=$(cat /dev/urandom | tr -dc '1-9' | fold -w 2 | head -n 1)
    DBPREFIX=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)_
    DP_URL="mysql://${DRUPAL_DB_USER}:${DRUPAL_DB_PASSWORD}@${DRUPAL_DB_HOST}/${DRUPAL_DB_NAME}"

    /var/www/html/vendor/drush/drush/drush site-install standard --yes \
      --db-url=${DP_URL} \
      --db-prefix=${DBPREFIX} \
      --site-name=${DRUPAL_SITE_NAME} \
      --account-name=${DRUPAL_USER_NAME} \
      --account-pass=${DRUPAL_PASSWORD} \
      --account-mail=${DRUPAL_USER_EMAIL}

    chown -R www-data:www-data /var/www/html/sites/default

    echo >&2 "========================================================================"
    echo >&2
    echo >&2 "DRUPAL! has been configured!"
    echo >&2
    echo >&2 "For the administrative access please use the following:"
    echo >&2 "Username: ${DRUPAL_USER_NAME}"
    echo >&2 "Password: [DRUPAL_PASSWORD] environment variable."
    echo >&2
    echo >&2 "========================================================================"
  else
    echo >&2 "========================================================================"
    echo >&2
    echo >&2 "This server is now configured to run Drupal"
    echo >&2
    echo >&2 "NOTE: You will need your database server address, database name,"
    echo >&2 "and database user credentials to install Drupal."
    echo >&2
    echo >&2 "========================================================================"
  fi

fi

# Enable server-status endpoint
sed -i '/RewriteCond %{REQUEST_FILENAME} !-f/i RewriteCond %{REQUEST_URI} !=/server-status' .htaccess

exec "$@"
