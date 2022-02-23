#!/usr/bin/env bash

# Copyright 2021 Google LLC
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
# limitations under the License.

# This script validates environment variables and configures
# required environment variables

set -e

# The platform being deployed, see 'case $CHEF_PLATFORM in'
if [ -z "$CHEF_PLATFORM" ]; then
    echo "CHEF_PLATFORM not set"
    exit 1
fi

# The GCP project to deploy to
if [ -z "$CHEF_GCP_PROJECT" ]; then
    echo "CHEF_GCP_PROJECT not set"
    exit 1
fi

# The GCP service account email
if [ -z "$CHEF_GCP_SA_EMAIL" ]; then
    echo "CHEF_GCP_SA_EMAIL not set"
    exit 1
fi

# The SSH username
if [ -z "$CHEF_SSH_USER" ]; then
    echo "CHEF_SSH_USER not set"
    exit 1
fi

# The file path for the ssh private key
if [ -z "$CHEF_SSH_KEY" ]; then
    echo "CHEF_SSH_KEY not set"
    exit 1
fi

# Test case path, such as 'test/integration/default'
if [ -z "$CHEF_TEST_DIR" ]; then
    echo "CHEF_TEST_DIR not set"
    exit 1
fi

# GOOGLE_APPLICATION_CREDENTIALS, usually set by action 'google-github-actions/setup-gcloud@master'
if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "GOOGLE_APPLICATION_CREDENTIALS not set"
    exit 1
fi

# Agent type (ops-agent, monitoring, logging)
if [ -z "$AGENT_TYPE" ]; then
    echo "AGENT_TYPE not set"
    exit 1
fi

# Agent version
if [ -z "$VERSION" ]; then
    echo "VERSION not set"
    exit 1
fi

# Package state
if [ -z "$STATE" ]; then
    echo "STATE not set"
    exit 1
fi

if [ -z "$CHEF_GCP_ZONE" ]; then
    echo "CHEF_GCP_ZONE not set"
    exit 1
fi

# Set image variables based on the platform
case $CHEF_PLATFORM in
  ubuntu-20.04)
    export CHEF_IMAGE_PROJECT="ubuntu-os-cloud"
    export CHEF_IMAGE_FAMILY="ubuntu-2004-lts"
    export CHEF_IMAGE_APPLICATION="ubuntu"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="2004"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  ubuntu-18.04)
    export CHEF_IMAGE_PROJECT="ubuntu-os-cloud"
    export CHEF_IMAGE_FAMILY="ubuntu-1804-lts"
    export CHEF_IMAGE_APPLICATION="ubuntu"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="1804"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  ubuntu-16.04)
    export CHEF_IMAGE_PROJECT="ubuntu-os-cloud"
    export CHEF_IMAGE_FAMILY="ubuntu-1604-lts"
    export CHEF_IMAGE_APPLICATION="ubuntu"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="1604"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  debian-10)
    export CHEF_IMAGE_PROJECT="debian-cloud"
    export CHEF_IMAGE_FAMILY="debian-10"
    export CHEF_IMAGE_APPLICATION="debian"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="10"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  debian-9)
    export CHEF_IMAGE_PROJECT="debian-cloud"
    export CHEF_IMAGE_FAMILY="debian-9"
    export CHEF_IMAGE_APPLICATION="debian"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="9"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  centos-s8)
    export CHEF_IMAGE_PROJECT="centos-cloud"
    export CHEF_IMAGE_FAMILY="centos-stream-8"
    export CHEF_IMAGE_APPLICATION="centos"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="8"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  centos-8)
    export CHEF_IMAGE_PROJECT="centos-cloud"
    export CHEF_IMAGE_FAMILY="centos-8"
    export CHEF_IMAGE_APPLICATION="centos"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="8"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  centos-7)
    export CHEF_IMAGE_PROJECT="centos-cloud"
    export CHEF_IMAGE_FAMILY="centos-7"
    export CHEF_IMAGE_APPLICATION="centos"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="7"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  almalinux-8)
    export CHEF_IMAGE_PROJECT="almalinux-cloud"
    export CHEF_IMAGE_FAMILY="almalinux-8"
    export CHEF_IMAGE_APPLICATION="almalinux"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="8"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  rocky-linux-8)
    export CHEF_IMAGE_PROJECT="rocky-linux-cloud"
    export CHEF_IMAGE_FAMILY="rocky-linux-8"
    export CHEF_IMAGE_APPLICATION="rocky-linux"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="8"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  rhel-8)
    export CHEF_IMAGE_PROJECT="rhel-cloud"
    export CHEF_IMAGE_FAMILY="rhel-8"
    export CHEF_IMAGE_APPLICATION="rhel"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="8"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  rhel-7)
    export CHEF_IMAGE_PROJECT="rhel-cloud"
    export CHEF_IMAGE_FAMILY="rhel-7"
    export CHEF_IMAGE_APPLICATION="rhel"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="7"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  sles-12)
    export CHEF_IMAGE_PROJECT="suse-cloud"
    export CHEF_IMAGE_FAMILY="sles-12"
    export CHEF_IMAGE_APPLICATION="suse"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="12"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  sles-15)
    export CHEF_IMAGE_PROJECT="suse-cloud"
    export CHEF_IMAGE_FAMILY="sles-15"
    export CHEF_IMAGE_APPLICATION="suse"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="15"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  opensuse-leap)
    export CHEF_IMAGE_PROJECT="opensuse-cloud"
    export CHEF_IMAGE_FAMILY="opensuse-leap"
    export CHEF_IMAGE_APPLICATION="opensuse"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="leap"
    export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
    ;;
  windows-2019)
    export CHEF_IMAGE_PROJECT="windows-cloud"
    export CHEF_IMAGE_FAMILY="windows-2019"
    export CHEF_IMAGE_APPLICATION="windows"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="2019-dc"
    export CHEF_CLIENT_URL=http://downloads.cinc.sh/files/stable/cinc/16.13.16/windows/2012r2/cinc-16.13.16-1-x64.msi
    ;;
  windows-2019-core)
    export CHEF_IMAGE_PROJECT="windows-cloud"
    export CHEF_IMAGE_FAMILY="windows-2019-core"
    export CHEF_IMAGE_APPLICATION="windows"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="2019-core"
    export CHEF_CLIENT_URL=http://downloads.cinc.sh/files/stable/cinc/16.13.16/windows/2012r2/cinc-16.13.16-1-x64.msi
    ;;
  windows-2016)
    export CHEF_IMAGE_PROJECT="windows-cloud"
    export CHEF_IMAGE_FAMILY="windows-2016"
    export CHEF_IMAGE_APPLICATION="windows"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="2016-dc"
    export CHEF_CLIENT_URL=http://downloads.cinc.sh/files/stable/cinc/16.13.16/windows/2012r2/cinc-16.13.16-1-x64.msi
    ;;
  windows-2016-core)
    export CHEF_IMAGE_PROJECT="windows-cloud"
    export CHEF_IMAGE_FAMILY="windows-2016"
    export CHEF_IMAGE_APPLICATION="windows"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="2016-core"
    export CHEF_CLIENT_URL=http://downloads.cinc.sh/files/stable/cinc/16.13.16/windows/2012r2/cinc-16.13.16-1-x64.msi
    ;;
  windows-2012r2)
    export CHEF_IMAGE_PROJECT="windows-cloud"
    export CHEF_IMAGE_FAMILY="windows-2012-r2"
    export CHEF_IMAGE_APPLICATION="windows"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="2012-r2-dc"
    export CHEF_CLIENT_URL=http://downloads.cinc.sh/files/stable/cinc/16.13.16/windows/2012r2/cinc-16.13.16-1-x64.msi
    ;;
  windows-2012r2-core)
    export CHEF_IMAGE_PROJECT="windows-cloud"
    export CHEF_IMAGE_FAMILY="windows-2012-r2"
    export CHEF_IMAGE_APPLICATION="windows"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="2012-r2-core"
    export CHEF_CLIENT_URL=http://downloads.cinc.sh/files/stable/cinc/16.13.16/windows/2012r2/cinc-16.13.16-1-x64.msi
    ;;
  windows-20h2-core)
    export CHEF_IMAGE_PROJECT="windows-cloud"
    export CHEF_IMAGE_FAMILY="windows-20h2-core"
    export CHEF_IMAGE_APPLICATION="windows"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="20h2-core"
    export CHEF_CLIENT_URL=http://downloads.cinc.sh/files/stable/cinc/16.13.16/windows/2012r2/cinc-16.13.16-1-x64.msi
    ;;
  windows-2004-core)
    export CHEF_IMAGE_PROJECT="windows-cloud"
    export CHEF_IMAGE_FAMILY="windows-2004-core"
    export CHEF_IMAGE_APPLICATION="windows"
    export CHEF_IMAGE_RELEASE="a"
    export CHEF_IMAGE_VERSION="2004-core"
    export CHEF_CLIENT_URL=http://downloads.cinc.sh/files/stable/cinc/16.13.16/windows/2012r2/cinc-16.13.16-1-x64.msi
    ;;
  *)
    echo "CHEF_PLATFORM ${CHEF_PLATFORM} not supported"
    exit 1
    ;;
esac

echo "deploying with variables:"
echo "${CHEF_IMAGE_FAMILY} ${CHEF_IMAGE_APPLICATION} ${CHEF_IMAGE_RELEASE} ${CHEF_IMAGE_VERSION}"
