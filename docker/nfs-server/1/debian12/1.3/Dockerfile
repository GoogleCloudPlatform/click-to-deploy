# Copyright 2016 The Kubernetes Authors.
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM marketplace.gcr.io/google/debian12@sha256:b93235fea71bd454ee11e8f857eb7c1672d033d426d9c0401c53df3c71fd52e7

ENV NFS_VERSION 1:2.6.2-4

ENV C2D_RELEASE 1.3.4

RUN set -x \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -qq -y openssl nfs-kernel-server=${NFS_VERSION}* \
    # Patch critical CVEs in base OS layer
    && apt-get install -y --only-upgrade libpcre2-8-0 perl perl-base zlib1g \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /exports

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +rx /usr/local/bin/docker-entrypoint.sh

VOLUME /exports

EXPOSE 2049/tcp
EXPOSE 20048/tcp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/exports"]
