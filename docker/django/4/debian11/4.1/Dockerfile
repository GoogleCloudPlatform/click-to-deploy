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


FROM marketplace.gcr.io/google/debian11

ENV C2D_RELEASE 4.1.5

ENV C2D_DJANGO_USER="django" \
    C2D_DJANGO_UID="8983" \
    C2D_DJANGO_GROUP="django" \
    C2D_DJANGO_GID="8983"

RUN set -ex; \
    groupadd -r --gid "${C2D_DJANGO_GID}" "${C2D_DJANGO_GROUP}"; \
    useradd -r --uid "${C2D_DJANGO_UID}" --gid "${C2D_DJANGO_GID}" "${C2D_DJANGO_USER}"

RUN apt-get update \
    && apt-get install -y \
      # MySQL dependencies
      default-libmysqlclient-dev \
      libmariadb-dev \
      # PostgreSQL dependencies
      libpq-dev \
      postgresql \
      postgresql-contrib \
      build-essential \
      curl \
      linux-libc-dev \
      net-tools \
      procps \
      python3 \
      python3-dev \
      python3-pip \
      tini \
      vim \
    && ln -s "$(which python3)" /usr/bin/python \
    && pip install \
        django \
        mysqlclient \
        psycopg2 \
        uwsgi \
    && mkdir -p /sites \
    && chown -R "${C2D_DJANGO_USER}:${C2D_DJANGO_GROUP}" /sites


COPY docker-entrypoint.sh /docker-entrypoint.sh
VOLUME /sites

USER "${C2D_DJANGO_USER}"

ENTRYPOINT ["/docker-entrypoint.sh"]
