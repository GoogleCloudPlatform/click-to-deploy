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
# Reference: https://docs.ghost.org/v1.0.0/docs/install
# Reference: https://www.linuxbabe.com/ubuntu/install-ghost-blog-ubuntu

apt_update 'update' do
  action :update
end

include_recipe 'mysql'
include_recipe 'nginx'
include_recipe 'nodejs'

file '/var/www/html/index.html' do
  action :delete
end

execute 'create db' do
  command "mysql -u root -e 'CREATE DATABASE #{node['ghost']['db']['name']};'"
end

execute 'install ghost-cli' do
  command "npm install -g ghost-cli@#{node['ghost']['cli']['version']}"
end

directory node['ghost']['app']['install_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

# Using Ghost-CLI programatically: https://docs.ghost.org/v1/docs/using-ghost-cli-programatically
bash 'install ghost' do
  user 'root'
  cwd node['ghost']['app']['install_dir']
  code <<-EOH
    ghost install "${version}" --no-prompt --no-setup --no-stack
    ghost config --no-prompt --url=http://localhost:2368 --db=mysql --dbhost=localhost --dbuser="${dbuser}" --dbname="${dbname}"
    ghost setup linux-user --no-prompt
EOH
  environment({
    'version' => node['ghost']['app']['version'],
    'dbuser' => node['ghost']['db']['user'],
    'dbname' => node['ghost']['db']['name'],
  })
end

c2d_startup_script 'ghost'
