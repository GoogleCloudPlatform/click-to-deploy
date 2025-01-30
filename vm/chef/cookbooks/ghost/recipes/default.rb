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
# Reference: https://ghost.org/docs/install/ubuntu/

apt_update 'update' do
  action :update
end

include_recipe 'mysql::version-8.0-embedded'
include_recipe 'nginx'
include_recipe 'nodejs::default_nodejs18'
include_recipe 'ghost::ospo'

file '/var/www/html/index.html' do
  action :delete
end

execute 'create db' do
  command "mysql -u root -e 'CREATE DATABASE #{node['ghost']['db']['name']};'"
end

execute 'install ghost-cli' do
  command "npm install -g ghost-cli@#{node['ghost']['cli']['version']}"
end

# Create ghost user.
user node['ghost']['user'] do
  home '/home/ghost_app'
  shell '/bin/bash'
  action :create
  manage_home true
end

# Assign permissions for install directory.
directory node['ghost']['app']['install_dir'] do
  owner node['ghost']['user']
  group node['ghost']['user']
  mode '0755'
  action :create
  recursive true
end

# Add ghost user to sudoers.
template "/opt/c2d/#{node['ghost']['user']}" do
  source 'etc-sudoers.d-ghost_app.erb'
  owner  'root'
  group  'root'
  mode   '0440'
  verify 'visudo -c -f %{path}'
  variables(ghost_app: node['ghost']['user'])
end

c2d_startup_script 'ghost'
