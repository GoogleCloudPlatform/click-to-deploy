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

# C2D_DJANGO_SITENAME - Site folder name
# C2D_DJANGO_PORT     - default_port

set -x

export C2D_DJANGO_PORT="${C2D_DJANGO_PORT:=8080}"

# If website is not ready
if [[ ! -d "${C2D_DJANGO_SITENAME}" ]]; then
  cd /sites

  # Create website
  django-admin startproject "${C2D_DJANGO_SITENAME}"

  # Configure for external access
  sed -i -e "s@ALLOWED_HOSTS = \[]@ALLOWED_HOSTS = ['.localhost', '127.0.0.1', '[::1]']@g" \
    "${C2D_DJANGO_SITENAME}/${C2D_DJANGO_SITENAME}/settings.py"

  # Run website migrations
  python3 "${C2D_DJANGO_SITENAME}/manage.py" migrate
fi

echo "Starting Django container..."

# Run uwsgi
cd "/sites/${C2D_DJANGO_SITENAME}" \
  && /usr/bin/tini uwsgi -- --http ":${C2D_DJANGO_PORT}" --module "${C2D_DJANGO_SITENAME}.wsgi"
