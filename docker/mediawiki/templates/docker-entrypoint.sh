#!/bin/bash
#
# Copyright (C) 2019  Google LLC
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

# Enable bash debug if DEBUG_DOCKER_ENTRYPOINT exists
if [[ ! -z "${DEBUG_DOCKER_ENTRYPOINT}" ]]; then
    echo "!!! WARNING: DEBUG_DOCKER_ENTRYPOINT is enabled!"
    echo "!!! WARNING: Use only for debugging. Do not use in production!"
    set -x
    env
fi

set -eu

# Default values
: ${MEDIAWIKI_ADMIN_USER:=admin}
: ${MEDIAWIKI_DB_NAME:=mediawiki}
: ${MEDIAWIKI_SITENAME:=my_first_wiki}

source /common_functions.sh

# 1. Prepare Installation
# ========================================
# Check if MediaWiki is already installed
# If Mediawiki is installed, do it
# otherwise, just start the container

if [[ "$(is_mediawiki_installed)" != "true" ]]; then
	CURRENT_FOLDER="$(pwd)"
	copy_installation_folder /mediawiki "${CURRENT_FOLDER}" LocalSettings.php

	# 2. Validating Input
	# =========================================

	REQUIRED_FIELDS=(
		"MEDIAWIKI_DBTYPE"
		"MEDIAWIKI_ADMIN_PASSWORD"
	)
	if [[ "$(validate_required_fields "${REQUIRED_FIELDS[@]}")" != "true" ]]; then
		echo >&2 "Required fields are missing."
		exit 1
	fi

	# Validate Database Type
	if [[ "${MEDIAWIKI_DBTYPE}" != "sqlite" ]] && [[ "${MEDIAWIKI_DBTYPE}" != "mysql" ]]; then
		echo >&2 "MEDIAWIKI_DBTYPE should contains: mysql or sqlite"
		exit 1
	fi

	# Validate MySQL/MariaDB fields
	if [[ "${MEDIAWIKI_DBTYPE}" == "mysql" ]]; then
		REQUIRED_FIELDS=(
			"MEDIAWIKI_DB_HOST"
			"MEDIAWIKI_DB_PORT"
			"MEDIAWIKI_DB_USER"
			"MEDIAWIKI_DB_PASSWORD"
		)
		if [[ "$(validate_required_fields "${REQUIRED_FIELDS[@]}")" != "true" ]]; then
			echo >&2 "Required fields are missing."
			exit 1
		fi
	fi

	# 3. Configuring Installation Parameters
	# =========================================

	# Declare default arguments
	ARGUMENTS=(
		"--confpath /var/www/html/"
		"--dbname ${MEDIAWIKI_DBNAME}"
		'--server [SERVER_HOST]'
		"--pass ${MEDIAWIKI_ADMIN_PASSWORD}"
		"--dbtype ${MEDIAWIKI_DBTYPE}"
		"--scriptpath [SCRIPT_PATH]"
	)

	# Declare MySQL/MariaDB-related arguments.
	if [[ "${MEDIAWIKI_DBTYPE}" == "mysql" ]]; then
		ARGUMENTS+=("--dbport ${MEDIAWIKI_DB_PORT}")
		ARGUMENTS+=("--dbserver ${MEDIAWIKI_DB_HOST}")
		ARGUMENTS+=("--dbuser ${MEDIAWIKI_DB_USER}")
		ARGUMENTS+=("--dbpass ${MEDIAWIKI_DB_PASSWORD}")

		echo "Awaiting MySQL to be ready..." >&2
		await_for_host_and_port "${MEDIAWIKI_DB_HOST}" "${MEDIAWIKI_DB_PORT}"
	fi

	# Declare last default arguments
	ARGUMENTS+=("${MEDIAWIKI_SITENAME}")
	ARGUMENTS+=("${MEDIAWIKI_ADMIN_USER}")


	# 4. Installing MediaWiki
	# ==================================

	# Run Installer
	php maintenance/install.php ${ARGUMENTS[@]}

	# If installer has failed, abort script
	if [[ "$?" -ne 0 ]]; then
		echo >&2 "Failure installing MediaWiki."
		exit 1
	fi

	# Replace settings
	CONFIG_FILE="LocalSettings.php"
	CUSTOM_CONFIG_FILE="/mediawiki-config/custom_settings.php"

	# Appends the custom config file to the end of current config
	cat "${CUSTOM_CONFIG_FILE}" >> "${CONFIG_FILE}"

	# If DBTYPE = sqlite, grants read access to Apache user.
	if [[ "${MEDIAWIKI_DBTYPE}" == "sqlite" ]]; then
		chown -R www-data:www-data /data
	fi
else
    echo "MediaWiki is already installed."
fi

echo "=================================="
echo " MediaWiki Succesfully Installed"
echo "----------------------------------"
echo " Username: ${MEDIAWIKI_ADMIN_USER}"
echo " Password: ${MEDIAWIKI_ADMIN_PASSWORD}"
echo "=================================="
echo "Starting container..."
exec "$@"
