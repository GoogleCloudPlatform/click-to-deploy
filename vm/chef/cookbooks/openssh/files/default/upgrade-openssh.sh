#!/bin/bash
#
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function backup_current_ssh() {
  local backup_dir="/opt/openssh_bkp"

  echo >&2 "Creating backup dir at: ${backup_dir} ..."
  mkdir -p "${backup_dir}"

  echo >&2 "- Backing up folder /etc/ssh ..."
  cp -rf /etc/ssh "${backup_dir}"

  echo >&2 "- Backing up folder /etc/pam.d ..."
  cp -rf /etc/pam.d "${backup_dir}"

  echo >&2 "- Backing up /etc/default/ssh ..."
  cp -f /etc/default/ssh "${backup_dir}/etc_default_ssh"

  echo >&2 "- Backing up folder /lib/systemd/system/ssh.service ..."
  cp -f /lib/systemd/system/ssh.service "${backup_dir}/ssh.service"

  echo >&2 "- Completed!"
}

# Restore backup
function restore_backup() {
  local backup_dir="/opt/openssh_bkp"

  echo >&2 "Restoring backup..."

  echo >&2 "- Restoring /etc/ssh/ ..."
  cp -rf "${backup_dir}/ssh/" /etc/

  echo >&2 "- Restoring /etc/pam.d/ ..."
  cp -rf "${backup_dir}/pam.d/" /etc/

  echo >&2 "- Restoring /etc/default/ssh ..."
  cp -f "${backup_dir}/etc_default_ssh" /etc/default/ssh

  echo >&2 "- Restoring /lib/systemd/system/ssh.service ..."
  cp -f "${backup_dir}/ssh.service" /lib/systemd/system/ssh.service

  cat >&2 /lib/systemd/system/ssh.service

  echo >&2 "- Completed!"
}

function download_new_version() {
  local -r version="${OPENSSH_VERSION}"
  local -r setup_folder="/opt/openssh"

  # Download
  echo >&2 "Downloading the version ${version}..."
  mkdir "${setup_folder}" && cd "${setup_folder}"

  echo >&2 "- Downloading to ${setup_folder} ..."
  curl -s -o openssh.tar.gz -L https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${version}.tar.gz

  # Extract
  echo >&2 "- Extracting ..."
  tar -xf openssh.tar.gz --strip-components=1

  echo >&2 "- Completed!"
}

# Uninstall openssh
function remove_current_version() {
  echo >&2 "Removing current version..."
  apt --quiet -y purge openssh-client
  echo >&2 "- Completed"
}

function setup_build_deps() {
  local -r command="$1"
  local -r -a packages=(
    build-essential
    zlib1g-dev
    libssl-dev
    libpam-dev
  )

  if [[ "${command}" != "install" && ""${command} != "uninstall" ]]; then
    echo >&2 "Invalid command."
    exit 1
  fi

  if [[ "${command}" == "install" ]]; then
    apt update -y
    echo >&2 "Installing build dependencies..."
    apt -y --quiet install "${packages[@]}"
  else
    echo >&2 "Uninstalling build dependencies..."
    apt -y --quiet purge "${packages[@]}"
  fi
}

# Install OpenSSH
function build_and_install_openssh() {
  set +e
  install -v -g sys -m700 -d /var/lib/sshd
  groupadd -g 51 sshd
  useradd  -c 'sshd PrivSep' \
            -d /var/lib/sshd  \
            -g 1000           \
            -G sshd           \
            -s /bin/false     \
            -u 50 sshd
  set -e


  ./configure --prefix=/usr                            \
              --sysconfdir=/etc/ssh                    \
              --with-privsep-path=/var/lib/sshd        \
              --with-default-path=/usr/bin             \
              --with-superuser-path=/usr/sbin:/usr/bin \
              --with-pam                               \
              --with-pid-dir=/run                      &&
  make

  make install && \
  install -v -m755    contrib/ssh-copy-id /usr/bin     && \

  install -v -m644    contrib/ssh-copy-id.1 \
                      /usr/share/man/man1              && \
  install -v -m755 -d "/usr/share/doc/openssh-${OPENSSH_VERSION}"     && \
  install -v -m644    INSTALL LICENCE OVERVIEW README* \
                      "/usr/share/doc/openssh-${OPENSSH_VERSION}"

  # Setup sftp-server
  make install
  install -v -m755  sftp-server  /usr/bin
  rm -f /usr/lib/openssh/sftp-server
  mkdir -p /usr/lib/openssh
  ln -s /usr/bin/sftp-server /usr/lib/openssh/sftp-server
}

function enable_service() {
  systemctl daemon-reload
  systemctl start ssh
  systemctl enable ssh
}

backup_current_ssh
download_new_version
remove_current_version
setup_build_deps "install"
build_and_install_openssh
restore_backup
enable_service

echo >&2 "Finished."
