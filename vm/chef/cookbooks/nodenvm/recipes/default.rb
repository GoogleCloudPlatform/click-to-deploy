# Copyright 2021 Google LLC
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

directory node['nvm']['dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

remote_file '/opt/c2d/install-nvm' do
  source "https://raw.githubusercontent.com/nvm-sh/nvm/v#{node['nvm']['version']}/install.sh"
  mode '0755'
  action :create
end

bash 'Install NVM' do
  code <<-EOH
    # Back up .bashrc.
    cp -f /root/.bashrc /root/.bashrc.bak

    # Install NVM
    export NVM_DIR="/usr/local/nvm"
    /opt/c2d/install-nvm

    # Restore backup and remove it.
    mv /root/.bashrc.bak /root/.bashrc

    # Import NVM
    source /usr/local/nvm/nvm.sh
EOH
end
