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

FROM marketplace.gcr.io/google/debian12 as ospo

# Download Licenses and restricted source-code
COPY components.csv /components.csv
COPY source_code.txt /source_code.txt

RUN apt update && apt -y install ca-certificates curl

RUN curl -o /download-licenses.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-licenses.sh \
	        && curl -o /download-ref-repos.sh -L https://raw.githubusercontent.com/GoogleCloudPlatform/click-to-deploy/master/scripts/download-ref-repos.sh \
	        && chmod +x /download-licenses.sh \
	        && chmod +x /download-ref-repos.sh

RUN mkdir -p /usr/src/licenses \
	        && /download-licenses.sh /components.csv /usr/src/licenses \
	        && /download-ref-repos.sh /source_code.txt /usr/src

FROM marketplace.gcr.io/google/debian12

COPY --from=ospo /usr/src /usr/src
ENV C2D_RELEASE 5.1.1

ENV C2D_DJANGO_USER="django" \
    C2D_DJANGO_UID="8983" \
    C2D_DJANGO_GROUP="django" \
    C2D_DJANGO_GID="8983"

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
      git \
      linux-libc-dev \
      net-tools \
      procps \
      python3 \
      python3-dev \
      python3-pip \
      python3-venv \
      pkg-config \
      tini \
      vim

RUN set -ex; \
    groupadd -r --gid "${C2D_DJANGO_GID}" "${C2D_DJANGO_GROUP}"; \
    useradd -r --uid "${C2D_DJANGO_UID}" --gid "${C2D_DJANGO_GID}" "${C2D_DJANGO_USER}"; \
    mkdir -p /sites; \
    chown "${C2D_DJANGO_UID}:${C2D_DJANGO_GROUP}" -R /sites/

# Set up a virtual environment
RUN python3 -m venv /sites/venv
ENV PATH="/sites/venv/bin:$PATH"

# Install Python packages in a virtual environment
RUN pip install --upgrade pip && \
    pip install \
        django==5.1.1 \
        mysqlclient \
        psycopg2 \
        uwsgi

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
VOLUME /sites
USER "${C2D_DJANGO_USER}"

ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]
