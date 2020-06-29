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

# Responsible for checking if MediaWiki is already installed inside the volume
function is_mediawiki_installed() {
    if [[ -f /var/www/html/LocalSettings.php ]]; then
        echo true
    else
        echo false
    fi
}

# Responsible for checking if a host and port are listening connections
# First parameter receives a host name
# Second parameter receives a port number
function await_for_host_and_port() {
    local HOST="$1"
    local PORT="$2"

    timeout --preserve-status 300 bash -c "
        until nc -vzw 5 ${HOST} ${PORT};
          do sleep 2;
        done"
}

# Responsible for copying an entire folder to a destination
# The usage of this function here is to copy the installation folder
# from container to a volume folder.
# If volume folder has already LocalSettings.php set bypass it
# It receives three parameters:
# First parameter - source folder
# Second parameter - destination folder
# Third parameter - lock file. If the file exists, no folder is copied.
function copy_installation_folder() {
    local FROM="$1"
    local TO="$2"
    local LOCK_FILE="$3"

    if [[ ! -f "${LOCK_FILE}" ]]; then
        echo "MediaWiki not found in ${TO} - copying now..." >&2
        if [[ "$(ls -A)" ]]; then
            echo "WARNING: ${TO} is not empty. Data might be overwritten." >&2
        fi
        tar cf - --one-file-system -C "${FROM}" . | tar xf -
        echo "MediaWiki has been successfully copied to ${TO}" >&2
    fi
}

# Responsible for testing all required fields
# If at least one required field is missing, script should be aborted
# User should be notified about the missing fields
# Returns true if all fields are valid, otherwise false
#
# Examples:
# - Test with missing fields:
#
#   export FIRST_NAME="John"
#   export LAST_NAME=""
#   REQUIRED_FIELDS=(
#       "FIRST_NAME"
#       "LAST_NAME"
#       "AGE"
#   )
#   echo "Result is: $(validate_required_fields)"
#   # => Outputs:
#   The following fields are required:
#   - LAST_NAME
#   - AGE
#   Result is: false
#
# - Test with valid fields:
#
#   export FIRST_NAME="John"
#   export LAST_NAME="Doe"
#   export AGE=40
#   REQUIRED_FIELDS=(
#       "FIRST_NAME"
#       "LAST_NAME"
#       "AGE"
#   )
#   echo "Result is: $(validate_required_fields)"
#   # => Outputs:
#   Result is: true
function validate_required_fields() {
    local FIELDS_TO_VALIDATE=("$@")
    local FIELDS_NON_FILLED=()
    local FIELD_VALUE

    # Validates field by field and add to errors if it is not filled.
    for field in "${FIELDS_TO_VALIDATE[@]}"; do
        FIELD_VALUE=$(eval echo "\$$field")
        if [[ -z "${FIELD_VALUE}" ]]; then
            FIELDS_NON_FILLED+=("${field}")
        fi
    done

    # Exits if there are some missing field.
    if [[ "${#FIELDS_NON_FILLED[@]}" -gt 0 ]]; then
        echo >&2 "The following fields are required:"
        for field in "${FIELDS_NON_FILLED[@]}"; do
            echo >&2 "- ${field}";
        done
        echo false
    else
        echo true
    fi
}
