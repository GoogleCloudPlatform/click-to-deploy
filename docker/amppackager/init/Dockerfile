# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.# This extra from is needed because of a bug in dockerfiles utility.
FROM gcr.io/cloud-marketplace/google/debian10

FROM gcr.io/cloud-marketplace/google/debian10 as init-container

RUN update-ca-certificates

# Git is required for fetching the dependencies.
RUN apt-get update \
    && apt-get install -y openssl \
    && apt-get install -y git

WORKDIR /data

COPY deploy.sh ./deploy.sh

RUN ["chmod", "+x", "./deploy.sh"]

COPY san_template.cnf ./san_template.cnf

COPY *.toml ./

# This env var is used by click-to-deploy deployer, right now needs to be
# manually synced with C2D_RELEASE in the other Docker images for AMP Packager
ENV C2D_RELEASE=1.0.0

CMD ["/bin/bash", "-c", "./deploy.sh"]]
