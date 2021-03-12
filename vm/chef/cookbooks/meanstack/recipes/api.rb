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

include_recipe 'meanstack::default'

nodenvm_npm 'Install Express Globally' do
  action :install_global
  package "express-generator@#{node['meanstack']['express']['version']}"
end

directory '/sites/api' do
  owner node['meanstack']['nginx']['user']
  group node['meanstack']['nginx']['group']
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
  package 'express'
end

nodenvm_npm 'Install Mongoose' do
  cwd '/sites/api'
  action :install
  package 'mongoose'
end

nodenvm_npm 'Install Body Parser' do
  cwd '/sites/api'
  action :install
  package 'body-parser'
end

cookbook_file '/sites/api/index.js' do
  source 'sample-api/index.js'
  owner node['meanstack']['nginx']['user']
  group node['meanstack']['nginx']['group']
  mode 0755
  action :create
end

cookbook_file '/sites/api/start.sh' do
  source 'sample-api/start.sh'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end
