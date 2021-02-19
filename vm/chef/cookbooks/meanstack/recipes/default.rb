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

include_recipe 'nginx'
include_recipe 'nodenvm'
include_recipe 'nodenvm::node14'
include_recipe 'mongodb::standalone'
include_recipe 'supervisord'

# API
directory '/sites/api' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

nodenvm_run 'Init API Application' do
  cwd '/sites/api'
  command 'npm init --force'
end

nodenvm_npm 'Install Express' do
  cwd '/sites/api'
  action :install
  package "express"
end

nodenvm_npm 'Install Mongoose' do
  cwd '/sites/api'
  action :install
  package "mongoose"
end

cookbook_file '/sites/api/index.js' do
  source 'sites/sample-api/index.js'
  owner 'www-data'
  group 'www-data'
  mode 0664
  action :create
end

cookbook_file '/sites/api/env_vars.sh' do
  source 'sites/sample-api/env_vars.sh'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

# Web App
nodenvm_npm 'Install Angular' do
  action :install_global
  package "@angular/cli@11.0.2"
end

nodenvm_run 'Create Angular Web Application' do
  cwd '/sites'
  command "ng new web --create-application --defaults --interactive=false"
end

# Front end webserver
directory '/sites/homepage' do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  recursive true
  action :create
end

cookbook_file '/sites/homepage/index.html' do
  source 'sites/sample-web/index.html'
  owner 'www-data'
  group 'www-data'
  mode 0664
  action :create
end

cookbook_file '/etc/nginx/sites-available/nginx-mean.conf' do
  source 'conf/nginx-mean.conf'
  owner 'root'
  group 'root'
  mode 0664
  action :create
end

# Configure supervisor
cookbook_file '/etc/supervisor/conf.d/supervisor-mean.conf' do
  source 'conf/supervisor-mean.conf'
  owner 'root'
  group 'root'
  mode 0664
  action :create
end

# Copy startup script
c2d_startup_script 'meanstack'
