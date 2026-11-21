# Copyright 2026 Google LLC
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

ARG NGINX_IMAGE=marketplace.gcr.io/google/nginx1:1.30
FROM ${NGINX_IMAGE}

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /home/nginx /var/cache/nginx /var/log/nginx /run /etc/nginx/cert \
    && groupmod -g 10000 nginx \
    && usermod -g 10000 -u 10000 -d /home/nginx -s /bin/bash nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && chown -R nginx:nginx /home/nginx /var/cache/nginx /var/log/nginx /run /etc/nginx

VOLUME ["/var/cache/nginx", "/var/log/nginx", "/run"]

STOPSIGNAL SIGQUIT

HEALTHCHECK CMD curl --fail -s http://localhost:8080 || exit 1

USER nginx

ENTRYPOINT []
CMD ["nginx", "-g", "daemon off;"]
