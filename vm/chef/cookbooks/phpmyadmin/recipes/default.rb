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
bash 'download phpmyadmin.deb and dependencies' do
  cwd '/opt/c2d/downloads'
  code <<-EOF
    mkdir -p /opt/c2d/downloads/phpmyadmin
    apt-get -d -o Dir::Cache::archives="/opt/c2d/downloads/phpmyadmin" \
    install phpmyadmin -y
EOF
end

c2d_startup_script 'phpmyadmin-setup'
