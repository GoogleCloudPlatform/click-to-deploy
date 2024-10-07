#!/bin/bash
#
# Copyright 2022 Google LLC
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:

#     1. Redistributions of source code must retain the above copyright notice,
#        this list of conditions and the following disclaimer.

#     2. Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.

#     3. Neither the name of Django nor the names of its contributors may be used
#        to endorse or promote products derived from this software without
#        specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -x

function await_for_host_and_port() {
    local host="$1"
    local port="$2"
    timeout --preserve-status 300 bash -c "until echo > /dev/tcp/${host}/${port}; do sleep 2; done"
    if [[ "$?" -ne 0 ]]; then
        exit 1
    fi
}

function setup_databases() {
  local -r settings_file="$1"

  if [[ "${C2D_DJANGO_DB_TYPE}" == "mysql" ]]; then
    apply_db_settings "${settings_file}" "django.db.backends.mysql"
  elif [[ "${C2D_DJANGO_DB_TYPE}" == "postgresql" ]]; then
    apply_db_settings "${settings_file}" "django.db.backends.postgresql"
  else
    log_info "Invalid DB provided"
    exit 1
  fi
}

function apply_db_settings() {
  local -r settings_file="$1"
  local -r db_driver="$2"

  local extra_config="$(cat <<-EOF
DATABASES = {
  'default': {
    'ENGINE': '${db_driver}',
    'NAME': '${C2D_DJANGO_DB_NAME}',
    'USER': '${C2D_DJANGO_DB_USER}',
    'PASSWORD': '${C2D_DJANGO_DB_PASSWORD}',
    'HOST': '${C2D_DJANGO_DB_HOST}',
    'PORT': '${C2D_DJANGO_DB_PORT}',
  }
}
EOF
)"
  echo "${extra_config}" >> "${settings_file}"
}

function setup_static_path() {
  local -r settings_file="$1"
  local -r static_path="/sites/${C2D_DJANGO_SITENAME}/static"
  mkdir -p "${static_path}"
  echo "STATIC_ROOT = '${static_path}'" >> "${settings_file}"
}

function log_info() {
  echo "====> $1"
}

export C2D_DJANGO_MODE="--${C2D_DJANGO_MODE:="socket"}"
export C2D_DJANGO_PORT="${C2D_DJANGO_PORT:=8080}"
export C2D_DJANGO_ALLOWED_HOSTS="${C2D_DJANGO_ALLOWED_HOSTS:="'localhost'"}"

declare -r SETTINGS_FILE="${C2D_DJANGO_SITENAME}/${C2D_DJANGO_SITENAME}/settings.py"

# If website is not ready
if [[ ! -d "${C2D_DJANGO_SITENAME}" ]]; then
  cd /sites

  # Create website
  log_info "Creating website..."
  django-admin startproject "${C2D_DJANGO_SITENAME}"

  # Configure for external access
  log_info "Setup for external access..."
  sed -i -e "s@ALLOWED_HOSTS = \[]@ALLOWED_HOSTS = [${C2D_DJANGO_ALLOWED_HOSTS}]@g" \
    "${C2D_DJANGO_SITENAME}/${C2D_DJANGO_SITENAME}/settings.py"

  # Setup databases
  if [[ ! -z "${C2D_DJANGO_DB_TYPE}" ]]; then
    echo "Setting up database configuration..."
    echo "Config: ${C2D_DJANGO_DB_TYPE}"
    env | grep "C2D_DJANGO_DB_" | grep -v "C2D_DJANGO_DB_PASSWORD"
    setup_databases "${SETTINGS_FILE}"

    echo "Awaiting for database..."
    await_for_host_and_port "${C2D_DJANGO_DB_HOST}" "${C2D_DJANGO_DB_PORT}"
  fi

  # Setting up static path
  setup_static_path "${SETTINGS_FILE}"

  # Run website migrations
  python3 "${C2D_DJANGO_SITENAME}/manage.py" makemigrations
  python3 "${C2D_DJANGO_SITENAME}/manage.py" migrate
  python3 "${C2D_DJANGO_SITENAME}/manage.py" collectstatic --noinput

else
  log_info "Website already found."
fi

echo "Starting Django container..."

# Run uwsgi
cd "/sites/${C2D_DJANGO_SITENAME}" \
  && /usr/bin/tini uwsgi -- "${C2D_DJANGO_MODE}" "0.0.0.0:${C2D_DJANGO_PORT}" --module "${C2D_DJANGO_SITENAME}.wsgi" --stats :1717 --py-autoreload 2 --lazy-apps --die-on-term
