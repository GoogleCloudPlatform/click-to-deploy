# Copyright 2018 Google LLC
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
#
# Reference: https://docs.phpmyadmin.net/en/latest/setup.html#debian
# Install phpmyadmin Note: on Debian, the config files are placed in /etc/phpmyadmin

# Download phpmyadmin and dependencies to /opt/c2d/downloads/phpmyadmin
# This allows us to install the package even after an apt-get clean

apt_update do
  action :update
end

package 'Install Packages' do
  package_name node['phpmyadmin']['packages']
  action :install
end

remote_file '/tmp/phpmyadmin.zip' do
  version = node['phpmyadmin']['version']
  source "https://files.phpmyadmin.net/phpMyAdmin/#{version}/phpMyAdmin-#{version}-all-languages.zip"
  checksum node['phpmyadmin']['sha256']
  action :create
end

bash 'Extract phpMyAdmin' do
  version = node['phpmyadmin']['version']
  user 'root'
  cwd '/tmp'
  code <<-EOH
    unzip /tmp/phpmyadmin.zip \
      -d /tmp/phpmyadmin \
    && mv /tmp/phpmyadmin/phpMyAdmin-#{version}-all-languages/ /opt/c2d/downloads/phpmyadmin \
    && rm -f /tmp/phpmyadmin.zip
EOH
end

c2d_startup_script 'phpmyadmin-setup'
