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
include_recipe 'nodejs::default_nodejs14'

file '/var/www/html/index.html' do
  action :delete
end

execute 'create db' do
  command "mysql -u root -e 'CREATE DATABASE #{node['ghost']['db']['name']};'"
end

execute 'install ghost-cli' do
  command "npm install -g ghost-cli@#{node['ghost']['cli']['version']}"
end

c2d_startup_script 'ghost'
