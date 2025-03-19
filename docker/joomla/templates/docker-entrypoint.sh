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
  if [[ -z ${JOOMLA_DB_HOST} ]]; then
    JOOMLA_DB_HOST='mysql'
  else
    echo >&2 "warning: both JOOMLA_DB_HOST and MYSQL_PORT_3306_TCP found"
    echo >&2 "  Connecting to JOOMLA_DB_HOST (${JOOMLA_DB_HOST})"
    echo >&2 "  instead of the linked mysql container"
  fi
fi

if [[ -z ${JOOMLA_DB_HOST} ]]; then
  echo >&2 "error: missing JOOMLA_DB_HOST and MYSQL_PORT_3306_TCP environment variables"
  echo >&2 "  Did you forget to --link some_mysql_container:mysql or set an external db"
  echo >&2 "  with -e JOOMLA_DB_HOST=hostname:port?"
  exit 1
fi

# If the DB user is 'root' then use the MySQL root password env var
: ${JOOMLA_DB_USER:=root}
if [[ ${JOOMLA_DB_USER} = 'root' ]]; then
  : ${JOOMLA_DB_PASSWORD:=${MYSQL_ENV_MYSQL_ROOT_PASSWORD}}
fi
: ${JOOMLA_DB_NAME:=joomla}

if [[ -z ${JOOMLA_DB_PASSWORD} ]]; then
  echo >&2 "error: missing required JOOMLA_DB_PASSWORD environment variable"
  echo >&2 "  Did you forget to -e JOOMLA_DB_PASSWORD=... ?"
  echo >&2
  echo >&2 "  (Also of interest might be JOOMLA_DB_USER and JOOMLA_DB_NAME.)"
  exit 1
fi

if [[ ${AUTO_INSTALL} = 'yes' ]]; then
  if [[ -z ${JOOMLA_PASSWORD} ]]; then
    echo >&2 "error: AUTO_INSTALL=yes required JOOMLA_PASSWORD environment variable"
    echo >&2 "  Did you forget to -e JOOMLA_PASSWORD=... ?"
    echo >&2
    echo >&2 "  (Also of interest might be JOOMLA_USER_NAME and JOOMLA_USER_EMAIL.)"
    exit 1
  fi
fi

# Ensure the MySQL Database is created
php /makedb.php "${JOOMLA_DB_HOST}" "${JOOMLA_DB_USER}" "${JOOMLA_DB_PASSWORD}" "${JOOMLA_DB_NAME}"

if ! [[ -e index.php && -e libraries/cms/version/version.php || -e libraries/src/Version.php ]]; then
  echo >&2 "Joomla not found in $(pwd) - copying now..."

  if [[ "$(ls -A)" && ${JOOMLA_NO_CHECK_VOLUME} != 'yes' ]]; then
    echo >&2 "error: $(pwd) is not empty."
    echo >&2 "  Did you forget to -e JOOMLA_NO_CHECK_VOLUME=yes ?"
    exit 1
  fi

  tar cf - --one-file-system -C /usr/src/joomla . | tar xf -

  if [[ ! -e .htaccess ]]; then
    # NOTE: The "Indexes" option is disabled in the php:apache base image
    #       so remove it as we enable .htaccess
    sed -r 's/^(Options -Indexes.*)$/#\1/' htaccess.txt > .htaccess
    # Disable redirect from server-status
    sed -i '/RewriteCond %{REQUEST_FILENAME} !-f/i RewriteCond %{REQUEST_URI} !=/server-status' .htaccess
    chown www-data:www-data .htaccess
  fi

  echo >&2 "Complete! Joomla has been successfully copied to $(pwd)"

  if [[ ${AUTO_INSTALL} = 'yes' ]]; then
    : ${JOOMLA_USER_NAME:='admin'}
    : ${JOOMLA_USER_EMAIL:='admin@example.com'}
    JOOMLA_USER_ID=$(cat /dev/urandom | tr -dc '1-9' | fold -w 2 | head -n 1)
    DBPREFIX=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)_

    sed -i "s/\$user = ''/\$user = '${JOOMLA_DB_USER}'/" installation/configuration.php-dist
    sed -i "s/\$password = ''/\$password = '${JOOMLA_DB_PASSWORD}'/" installation/configuration.php-dist
    sed -i "s/\$db = ''/\$db = '${JOOMLA_DB_NAME}'/" installation/configuration.php-dist
    sed -i "s/\$host = 'localhost'/\$host = '${JOOMLA_DB_HOST}'/" installation/configuration.php-dist
    sed -i "s/\$dbprefix = 'jos_'/\$dbprefix = '${DBPREFIX}'/" installation/configuration.php-dist
    sed -i "s/\$log_path = '\/administrator\/logs'/\$log_path = '\/var\/www\/html\/administrator\/logs'/" installation/configuration.php-dist
    cp installation/configuration.php-dist configuration.php
    chown www-data:www-data configuration.php

    # To prevent DB disruption, during the installation Joomla! creates new tables with a random prefix.
    # In the joomla.sql #__ means the prefix. Ignores sample files
    declare scripts="$(ls -1 -I "sample*" installation/sql/mysql/)"
    for script in $scripts; do
      sed -i "s/#__/${DBPREFIX}/" "installation/sql/mysql/${script}"
      cat "installation/sql/mysql/${script}" | \
        mysql -h ${JOOMLA_DB_HOST} -u ${JOOMLA_DB_USER} --password=${JOOMLA_DB_PASSWORD} ${JOOMLA_DB_NAME}
    done

    # create joomla user
    JOOMLA_ENC_PASS="$(echo -n "${JOOMLA_PASSWORD}" | md5sum | awk '{ print $1 }' )"
    echo "INSERT INTO \`${DBPREFIX}users\` \
      (\`id\`, \`name\`, \`username\`, \`email\`, \`password\`, \
      \`block\`, \`sendEmail\`, \`registerDate\`, \`lastvisitDate\`, \
      \`activation\`, \`params\`, \`lastResetTime\`, \`resetCount\`, \
      \`otpKey\`, \`otep\`, \`requireReset\`) VALUES ('${JOOMLA_USER_ID}', \
      '${JOOMLA_USER_NAME}', '${JOOMLA_USER_NAME}', '${JOOMLA_USER_EMAIL}', \
      '${JOOMLA_ENC_PASS}', '0', '0', '$(date +%Y-%m-%d)', '$(date +%Y-%m-%d)', \
      '', '', '$(date +%Y-%m-%d)', '0', '', '', '0');" | \
      mysql -h ${JOOMLA_DB_HOST} -u ${JOOMLA_DB_USER} \
      --password=${JOOMLA_DB_PASSWORD} ${JOOMLA_DB_NAME}
    echo "INSERT INTO \`${DBPREFIX}user_usergroup_map\` \
      (\`user_id\`, \`group_id\`) VALUES ('${JOOMLA_USER_ID}', '8');" | \
      mysql -h ${JOOMLA_DB_HOST} -u ${JOOMLA_DB_USER} \
      --password=${JOOMLA_DB_PASSWORD} ${JOOMLA_DB_NAME}

    rm -rf installation/
    echo >&2 "========================================================================"
    echo >&2
    echo >&2 "Joomla! has been configured!"
    echo >&2
    echo >&2 "For the administrative access please use the following:"
    echo >&2 "Username: ${JOOMLA_USER_NAME}"
    echo >&2 "Password: ${JOOMLA_PASSWORD}"
    echo >&2
    echo >&2 "========================================================================"
  else
    echo >&2 "========================================================================"
    echo >&2
    echo >&2 "This server is now configured to run Joomla!"
    echo >&2
    echo >&2 "NOTE: You will need your database server address, database name,"
    echo >&2 "and database user credentials to install Joomla."
    echo >&2
    echo >&2 "========================================================================"
  fi

fi

exec "$@"
