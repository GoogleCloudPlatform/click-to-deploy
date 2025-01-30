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
#
# Reference: https://github.com/getredash/setup
include_recipe 'docker'
include_recipe 'docker::compose'
include_recipe 'redash::ospo'

# Update sources
apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

# Install Deps Packages
package 'Install Deps Packages' do
  action :install
  package_name node['redash']['packages']
end

group node['redash']['linux']['user'] do
end

user node['redash']['linux']['user'] do
  comment 'default redash user'
  gid node['redash']['linux']['user']
  home node['redash']['path']
end

remote_file '/tmp/redash.tar.gz' do
  source "https://github.com/getredash/redash/archive/refs/tags/v#{node['redash']['version']}.tar.gz"
  verify "echo '#{node['redash']['sha1']} %{path}' | sha1sum -c"
  action :create
end

bash 'add user to docker group' do
  user 'root'
  code <<-EOH
    usermod -aG docker $redash_user
    EOH
  environment({
    'redash_user' => node['redash']['linux']['user'],
  })
end

bash 'create redash folder' do
  user 'root'
  code <<-EOH
    mkdir -p $redash_path
    mkdir -p $redash_path/postgres-data
    chown -R $redash_user:$redash_user $redash_path
  EOH
  environment({
    'redash_user' => node['redash']['linux']['user'],
    'redash_path' => node['redash']['path'],
  })
end

bash 'install redash' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    # Extract to $redash_path and remove temp file
    tar -xf redash.tar.gz -C $redash_path --strip-components 1
    chown -R $user:$user $redash_path
    chmod -R 755 $redash_path
    rm redash.tar.gz
  EOH
  environment({
    'user' => node['redash']['linux']['user'],
    'redash_path' => node['redash']['path'],
  })
end

remote_file 'Download composer manifest' do
  path '/opt/redash/setup/docker-compose.yml'
  source 'https://raw.githubusercontent.com/getredash/setup/master/data/compose.yaml'
end

c2d_startup_script 'redash-setup'
